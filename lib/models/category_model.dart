class CategoryModel {
  final String id;
  final String name;
  final String slug;
  final String? description;
  final String? image;
  final String status;
  final int displayOrder;
  final String? parentId;

  CategoryModel({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    this.image,
    this.status = 'ACTIVE',
    this.displayOrder = 0,
    this.parentId,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String? ?? '',
      description: json['description'] as String?,
      image: json['image'] as String?,
      status: json['status'] as String? ?? 'ACTIVE',
      displayOrder: json['displayOrder'] as int? ?? 0,
      parentId: json['parentId'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'slug': slug,
        'description': description,
        'image': image,
        'status': status,
        'displayOrder': displayOrder,
        'parentId': parentId,
      };
}
