import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../models/category.dart';
import '../models/item.dart';
import '../providers/catalog_provider.dart';
import '../providers/nav_provider.dart';
import '../services/api_client.dart';
import '../services/item_service.dart';
import '../theme.dart';
import '../widgets/app_button.dart';
import '../widgets/app_dropdown.dart';
import '../widgets/app_text_field.dart';
import '../widgets/app_toast.dart';
import '../widgets/panel.dart';
import '../widgets/section_title.dart';

/// "Post an item". Also used to edit a listing: [editing] pre-fills the form.
class PostItemScreen extends StatefulWidget {
  const PostItemScreen({super.key, this.editing});

  final Item? editing;

  @override
  State<PostItemScreen> createState() => _PostItemScreenState();
}

class _PostItemScreenState extends State<PostItemScreen> {
  final _title = TextEditingController();
  final _price = TextEditingController();
  final _description = TextEditingController();
  int? _categoryId;
  String _condition = kConditionOptions.first;
  XFile? _photo;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final e = widget.editing;
    if (e != null) {
      _title.text = e.title;
      _price.text = '${e.price}';
      _description.text = e.description;
      _categoryId = e.category.id;
      if (kConditionOptions.contains(e.conditionLabel)) _condition = e.conditionLabel;
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _price.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    try {
      final file = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1600, // smaller uploads are faster on a slow connection
        imageQuality: 80,
      );
      if (file != null && mounted) setState(() => _photo = file);
    } catch (_) {
      showToast('Could not open your photos');
    }
  }

  Future<void> _submit() async {
    final title = _title.text.trim();
    final price = int.tryParse(_price.text.trim()) ?? 0;
    final description = _description.text.trim();
    if (title.isEmpty || price <= 0 || description.isEmpty) {
      showToast('Enter item name, valid price and description');
      return;
    }

    final catalog = context.read<CatalogProvider>();
    final categoryId = _categoryId ?? (catalog.categories.isEmpty ? null : catalog.categories.first.id);
    if (categoryId == null) {
      showToast('Categories could not be loaded. Check your connection and try again.');
      catalog.loadCategories();
      return;
    }

    FocusScope.of(context).unfocus();
    final items = context.read<ItemService>();
    final nav = context.read<NavProvider>();
    final editing = widget.editing;
    setState(() => _saving = true);
    try {
      final saved = editing == null
          ? await items.create(
              categoryId: categoryId,
              title: title,
              description: description,
              price: price,
              condition: conditionToApi(_condition),
              pickupLocation: null,
            )
          : await items.update(
              editing.id,
              categoryId: categoryId,
              title: title,
              description: description,
              price: price,
              condition: conditionToApi(_condition),
              pickupLocation: editing.pickupLocation,
            );
      final photo = _photo;
      if (photo != null) {
        try {
          await items.uploadImage(saved.id, photo.path);
        } on ApiException catch (e) {
          showToast('Saved, but the photo was not uploaded: ${e.message}');
        }
      }
      await catalog.refresh();
      if (!mounted) return;
      showToast(editing == null ? 'Your listing is published' : 'Listing updated');
      if (editing == null) {
        _title.clear();
        _price.clear();
        _description.clear();
        setState(() => _photo = null);
        nav.go(AppPage.orders);
      } else {
        nav.finishEditing();
      }
    } on ApiException catch (e) {
      showToast(e.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = context.watch<CatalogProvider>().categories;
    final editing = widget.editing != null;
    final selected = _categoryId ?? (categories.isEmpty ? null : categories.first.id);

    return ListView(
      padding: const EdgeInsets.fromLTRB(15, 15, 15, 20),
      children: [
        SectionTitle(editing ? 'Edit item' : 'Post an item', editing ? 'Update your listing' : 'Reach student buyers'),
        Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTextField(controller: _title, label: 'Item name', hint: 'What are you selling?'),
              AppTextField(
                controller: _price,
                label: 'Price (UGX)',
                hint: 'e.g. 150000',
                keyboardType: TextInputType.number,
              ),
              AppDropdown<int>(
                label: 'Category',
                value: selected != null && categories.any((c) => c.id == selected) ? selected : null,
                options: [for (final Category c in categories) c.id],
                optionLabel: (id) => categories.singleWhere((c) => c.id == id).name,
                onChanged: (id) => setState(() => _categoryId = id),
              ),
              AppDropdown<String>(
                label: 'Condition',
                value: _condition,
                options: kConditionOptions,
                optionLabel: (label) => label,
                onChanged: (label) => setState(() => _condition = label ?? _condition),
              ),
              AppTextField(
                controller: _description,
                label: 'Description',
                hint: 'Tell buyers about your item...',
                maxLines: 4,
                keyboardType: TextInputType.multiline,
              ),
              const Padding(
                padding: EdgeInsets.only(top: 12, bottom: 6),
                child: Text('Add photos', style: TextStyle(color: AppColors.label, fontSize: 12)),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.inputBg,
                  border: Border.all(color: AppColors.line),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Row(
                  children: [
                    AppButton(label: 'Choose file', secondary: true, onPressed: _pickPhoto),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _photo?.name ?? 'No file chosen',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: AppColors.muted, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              AppButton(
                label: editing ? 'Save changes' : 'Publish listing',
                full: true,
                loading: _saving,
                onPressed: _submit,
              ),
              const SizedBox(height: 14),
              const Text(
                'Your listing is visible to other students once it is published.',
                style: TextStyle(fontSize: 11, color: AppColors.muted),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
