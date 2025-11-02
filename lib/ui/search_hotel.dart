import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:myhotx/cubit/cubit_auto.dart';
import 'package:myhotx/cubit/cubit_hotel.dart';
import 'package:myhotx/model/popular_stay_model.dart';
import 'package:myhotx/model/search_autocomplete_model.dart';

class SearchHotelScreen extends StatefulWidget {
  const SearchHotelScreen({super.key});

  @override
  State<SearchHotelScreen> createState() => _SearchHotelScreenState();
}

class _SearchHotelScreenState extends State<SearchHotelScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<Property> _properties = [];
  final List<Property> _filteredProperties = [];
  final ScrollController _scrollController = ScrollController();
  HotalListCubit? cubit;
  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;
  @override
  void initState() {
    super.initState();
    _initializeCubit();
    _searchController.addListener(_filterProperties);

    _scrollController.addListener(_onScroll);
  }

  void _initializeCubit() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      cubit = context.read<HotalListCubit>();
      cubit?.getHotelList(context);

      // Listen to the ValueNotifier changes
      cubit?.hotalListNotifier.addListener(_onHotelListUpdated);
    });
  }

  void _onHotelListUpdated() {
    if (cubit?.hotalListNotifier.value != null) {
      setState(() {
        _properties.clear();
        _properties.addAll(cubit!.hotalListNotifier.value);
        _filteredProperties.clear();
        _filteredProperties.addAll(_properties);
      });
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      // Load more when scrolled to bottom
      cubit?.loadMore;
    }
  }

  void _filterProperties() {
    final query = _searchController.text.trim().toLowerCase();
    final allProperties = cubit?.hotalListNotifier.value ?? [];

    if (query.isEmpty) {
      setState(() {
        _filteredProperties.clear();
        _filteredProperties.addAll(allProperties);
      });
      return;
    }

    setState(() {
      _filteredProperties.clear();
      _filteredProperties.addAll(
        allProperties.where((property) {
          return property.propertyName.toLowerCase().contains(query) ||
              (property.propertyAddress?.city?.toLowerCase().contains(query) ??
                  false) ||
              (property.propertyAddress?.state?.toLowerCase().contains(query) ??
                  false) ||
              (property.propertyAddress?.country?.toLowerCase().contains(
                    query,
                  ) ??
                  false) ||
              (property.propertyAddress?.street?.toLowerCase().contains(
                    query,
                  ) ??
                  false);
        }),
      );
    });
  }

  Future<void> getDataShared() async {
    cubit?.refresh;
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    cubit?.hotalListNotifier.removeListener(_onHotelListUpdated);
    super.dispose();
  }

  void _onSearchChanged(BuildContext context, String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (query.isNotEmpty) {
        context.read<AutoSearchListCubit>().getAutoSearchList(
          context,
          queryX: query,
          isLoader: false,
        );
      } else {
        context.read<AutoSearchListCubit>().autoSearchListNotifier.value = [];
      }
    });
  }

  Widget _buildLoadingMoreIndicator() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildNoMoreItems() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: Text(
          'No more properties to load',
          style: TextStyle(color: Colors.grey[600], fontSize: 14),
        ),
      ),
    );
  }

  Widget _buildPropertyCard(Property property) {
    final List<Map<String, dynamic>> amenities = [];

    if (property.propertyPoliciesAndAmmenities?.data?.freeWifi == true) {
      amenities.add({"icon": Icons.wifi, "label": "Free Wifi"});
    }
    if (property.propertyPoliciesAndAmmenities?.data?.coupleFriendly == true) {
      amenities.add({"icon": Icons.favorite, "label": "Couple Friendly"});
    }
    if (property.propertyPoliciesAndAmmenities?.data?.freeCancellation ==
        true) {
      amenities.add({"icon": Icons.cancel, "label": "Free Cancellation"});
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      property.propertyImage,
                      width: 110,
                      height: 110,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 110,
                          height: 110,
                          color: Colors.grey[200],
                          child: const Icon(
                            Icons.hotel,
                            color: Colors.grey,
                            size: 40,
                          ),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          width: 110,
                          height: 110,
                          color: Colors.grey[200],
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    property.staticPrice?.displayAmount ?? 'N/A',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                  const Text(
                    '/night',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            property.propertyName,
                            style: GoogleFonts.poppins(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    // Location Row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${property.propertyAddress?.city ?? ''}, ${property.propertyAddress?.state ?? ''}, ${property.propertyAddress?.country ?? ''}',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        _buildPropertyTypeBadge(property.propertyType),
                      ],
                    ),

                    const SizedBox(height: 8),

                    if (amenities.isNotEmpty)
                      if (amenities.isNotEmpty)
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: amenities.map((a) {
                              return Container(
                                margin: const EdgeInsets.only(right: 8),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.blue.shade100,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      a['icon'],
                                      size: 14,
                                      color: Colors.blue.shade700,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      a['label'],
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: Colors.blue.shade800,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),

                    const SizedBox(height: 8),

                    // Rating
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          (property.googleReview?.data?.overallRating ?? 0)
                              .toStringAsFixed(1),
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '(${property.googleReview?.data?.totalUserRating ?? 0} reviews)',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPropertyTypeBadge(String type) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        type.toUpperCase(),
        style: GoogleFonts.poppins(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: Colors.blue[800],
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: Colors.grey[700]),
            const SizedBox(width: 6),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildResultTile(SearchResult result) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Location icon
              Container(
                margin: const EdgeInsets.only(right: 12, top: 2),
                child: Icon(
                  Icons.location_on_outlined,
                  color: const Color(0xFF6C63FF),
                  size: 20,
                ),
              ),

              // Text content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name
                    Text(
                      result.valueToDisplay ?? "Unknown",
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF2C2C2C),
                        fontSize: 15,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 4),

                    // Address
                    if (result.address != null)
                      Text(
                        "${result.address?.city ?? ''}${result.address?.state != null ? ', ${result.address!.state}' : ''}",
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Divider line
        Divider(
          height: 1,
          thickness: 1,
          color: Colors.grey.withOpacity(0.2),
          indent: 16,
          endIndent: 16,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<HotalListCubit>();

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard'), actions: [
          
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ValueListenableBuilder<List<Property>>(
              valueListenable: cubit.hotalListNotifier,
              builder: (context, members, _) {
                final displayProperties = _searchController.text.isEmpty
                    ? members
                    : _filteredProperties;

                if (displayProperties.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.hotel_outlined,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchController.text.isEmpty
                              ? "No properties found"
                              : "No matching properties found",
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async => cubit.refresh,
                  child: ListView.builder(
                    controller: _scrollController,

                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    itemCount:
                        displayProperties.length +
                        (_searchController.text.isEmpty ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (_searchController.text.isEmpty &&
                          index == displayProperties.length) {
                        if (cubit.hasMoreNotifier.value) {
                          return _buildLoadingMoreIndicator();
                        } else if (displayProperties.isNotEmpty) {
                          return _buildNoMoreItems();
                        }
                        return SizedBox.shrink();
                      }

                      final member = displayProperties[index];
                      return _buildPropertyCard(member);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
