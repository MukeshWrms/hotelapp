import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:myhotx/cubit/cubit_search_hotel.dart';

import 'package:myhotx/model/search_hotel.dart';

class HotelSearchResultScreen extends StatefulWidget {
  final Map<String, dynamic> payload;

  const HotelSearchResultScreen({Key? key, required this.payload})
    : super(key: key);

  @override
  State<HotelSearchResultScreen> createState() =>
      _HotelSearchResultScreenState();
}

class _HotelSearchResultScreenState extends State<HotelSearchResultScreen> {
  late final HotalSearchListCubit cubit;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  List<PropertySearch> _filteredProperties = [];

  @override
  void initState() {
    super.initState();
    cubit = context.read<HotalSearchListCubit>();

    // Initial API call
    WidgetsBinding.instance.addPostFrameCallback((_) {
      cubit.getBookingHotelList(context, payload: widget.payload);
    });

    // Infinite scroll listener - optimized for 5 records
    _scrollController.addListener(() {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;

      // Load more when 80% scrolled and conditions are met
      if (currentScroll >= (maxScroll * 0.8) &&
          !cubit.isLoadingSearchMoreNotifier.value &&
          cubit.hasSearchMoreNotifier.value) {
        print(
          'Scroll detected at ${currentScroll.toInt()}/ ${maxScroll.toInt()} - loading more...',
        );
        cubit.loadMore();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Search Results",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
      ),
      body: ValueListenableBuilder<List<PropertySearch>>(
        valueListenable: cubit.hotalSearchListNotifier,
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
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => cubit.refresh(),
            child: ListView.builder(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 16),
              itemCount:
                  displayProperties.length +
                  (cubit.hasSearchMoreNotifier.value ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == displayProperties.length &&
                    cubit.hasSearchMoreNotifier.value) {
                  return _buildLoadingMoreIndicator();
                }
                if (index == displayProperties.length &&
                    !cubit.hasSearchMoreNotifier.value &&
                    displayProperties.isNotEmpty) {
                  return _buildNoMoreItems();
                }
                final property = displayProperties[index];
                return _buildPropertyCard(property);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingMoreIndicator() => const Padding(
    padding: EdgeInsets.all(16.0),
    child: Center(child: CircularProgressIndicator()),
  );

  Widget _buildNoMoreItems() => Padding(
    padding: const EdgeInsets.all(16.0),
    child: Center(
      child: Text(
        "No more properties to load",
        style: TextStyle(color: Colors.grey[600], fontSize: 14),
      ),
    ),
  );

  Widget _buildPropertyCard(PropertySearch property) {
    final List<Map<String, dynamic>> amenities = [];

    if (cubit.hasFreeWifi(property)) {
      amenities.add({"icon": Icons.wifi, "label": "Free Wifi"});
    }
    if (cubit.isCoupleFriendly(property)) {
      amenities.add({"icon": Icons.favorite, "label": "Couple Friendly"});
    }
    if (cubit.hasFreeCancellation(property)) {
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
                      cubit.getPropertyImageUrl(property),
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
                    cubit.getDisplayPrice(property),
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
                            cubit.getLocationString(property),
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
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: amenities.map((a) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  a['icon'],
                                  size: 14,
                                  color: Colors.blue[700],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  a['label'],
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Colors.blue[800],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),

                    const SizedBox(height: 8),

                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          cubit.getRating(property).toStringAsFixed(1),
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '(${cubit.getReviewCount(property)} reviews)',
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

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }
}
