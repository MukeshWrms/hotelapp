import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:myhotx/api/api_payload.dart';
import 'package:myhotx/cubit/cubit_auto.dart';
import 'package:myhotx/cubit/cubit_hotel.dart';
import 'package:myhotx/cubit/cubit_search_hotel.dart';
import 'package:myhotx/model/popular_stay_model.dart';
import 'package:myhotx/model/search_autocomplete_model.dart';

import 'package:myhotx/ui/hotel_search_result_screen.dart';

class DashboardScreenX extends StatefulWidget {
  const DashboardScreenX({super.key});

  @override
  State<DashboardScreenX> createState() => _DashboardScreenXState();
}

class _DashboardScreenXState extends State<DashboardScreenX> {
  bool _showSuggestions = false;
  final TextEditingController _searchController = TextEditingController();
  final List<Property> _properties = [];
  final List<Property> _filteredProperties = [];
  final ScrollController _scrollController = ScrollController();
  HotalListCubit? cubit;
  final TextEditingController _controller = TextEditingController();
  List<String> searchQueryHotel = [];
  DateTime? _selectedCheckInDate;
  DateTime? _selectedCheckOutDate;
  final TextEditingController _checkInController = TextEditingController();
  final TextEditingController _checkOutController = TextEditingController();

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
      cubit?.loadMore();
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
    cubit?.refresh();
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
      child: Center(child: SpinKitCircle(color: Colors.red, size: 50)),
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

  Widget _buildUserInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        //color: Colors.grey[50],
        // border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(
              "https://avatars.githubusercontent.com/u/51777681?v=4" ?? '',
            ),
            radius: 20,
            onBackgroundImageError: (exception, stackTrace) {
              // Handle image loading error
            },
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Mukesh Kumar" ?? 'No Name',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 1),
                Text(
                  "mukesh.wrms@gmail.com",
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
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

  //date check in check out
  Widget _buildInfoItem({
    required IconData icon,
    required String title,
    required String value,
    bool isCheckInDate = false,
    bool isCheckOutDate = false,
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
        // Check-in Date
        if (isCheckInDate)
          GestureDetector(
            onTap: () => _selectCheckInDate(),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _selectedCheckInDate != null
                        ? DateFormat(
                            'MMM dd, yyyy',
                          ).format(_selectedCheckInDate!)
                        : 'Check In',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: _selectedCheckInDate != null
                          ? Colors.black
                          : Colors.grey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  //   Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                ],
              ),
            ),
          )
        // Check-out Date
        else if (isCheckOutDate)
          GestureDetector(
            onTap: () => _selectCheckOutDate(),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _selectedCheckOutDate != null
                        ? DateFormat(
                            'MMM dd, yyyy',
                          ).format(_selectedCheckOutDate!)
                        : 'Check out',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: _selectedCheckOutDate != null
                          ? Colors.black
                          : Colors.grey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  // Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                ],
              ),
            ),
          )
        // Regular info item
        else
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

  // Date selection methods
  Future<void> _selectCheckInDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedCheckInDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: Colors.blue),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedCheckInDate) {
      setState(() {
        _selectedCheckInDate = picked;
        _checkInController.text = DateFormat('yyyy-MM-dd').format(picked);

        // If check-out date is before new check-in date, reset check-out
        if (_selectedCheckOutDate != null &&
            _selectedCheckOutDate!.isBefore(picked)) {
          _selectedCheckOutDate = null;
          _checkOutController.clear();
        }
      });
    }
  }

  Future<void> _selectCheckOutDate() async {
    final DateTime firstDate =
        _selectedCheckInDate?.add(const Duration(days: 1)) ??
        DateTime.now().add(const Duration(days: 1));

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedCheckOutDate ?? firstDate,
      firstDate: firstDate,
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: Colors.blue),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedCheckOutDate) {
      setState(() {
        _selectedCheckOutDate = picked;
        _checkOutController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  //code end
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

  // Helper method for booking details
  Widget _buildBookingDetails() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildInfoItem(
              icon: Icons.calendar_today,
              title: 'Check In',
              value: '',
              isCheckInDate: true,
            ),
            const SizedBox(height: 16),
            _buildInfoItem(
              icon: Icons.calendar_today,
              title: 'Check Out',
              value: '',
              isCheckOutDate: true,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildInfoItem(
              icon: Icons.meeting_room_rounded,
              title: "Rooms",
              value: "1 Room",
            ),
            _buildInfoItem(
              icon: Icons.person_outline_rounded,
              title: "Guests",
              value: "1 Adult",
            ),
          ],
        ),
        const SizedBox(height: 24),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF5B6FFF), Color(0xFF8C6FE9)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(30),
          ),
          child: ElevatedButton.icon(
            onPressed: () async {
              // Handle search action
              print(searchQueryHotel);
              final payload = await ApiPayload.inst
                  .getSearchResultListOfHotelsPayload(
                    checkIn: _checkInController.text, //"2025-12-24",
                    checkOut: _checkOutController.text, //"2025-12-25",
                    rooms: 1,
                    adults: 1,
                    searchQuery:
                        searchQueryHotel, // ["AFTNXAjd"] delhi, //["a_UvAsCc"] bangl..,
                  );

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: context.read<HotalSearchListCubit>(),
                    child: HotelSearchResultScreen(payload: payload),
                  ),
                ),
              );
            },
            icon: const Icon(Icons.search, color: Colors.white),
            label: Text(
              "Search",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<HotalListCubit>();
    final cubitX = context.read<AutoSearchListCubit>();
    return Scaffold(
      appBar: AppBar(
        title: _buildUserInfo(),
        actions: [
          // IconButton(
          //   onPressed: () {},
          //   icon: const Icon(Icons.logout),
          //   tooltip: 'Logout',
          // ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _controller,
                          onChanged: (query) {
                            _onSearchChanged(context, query);
                            setState(() {
                              _showSuggestions = query.isNotEmpty;
                            });
                          },
                          decoration: const InputDecoration(
                            prefixIcon: Icon(
                              Icons.search,
                              color: Color(0xFF6C63FF),
                            ),
                            hintText: "Search hotels, cities, or streets...",
                            border: InputBorder.none,
                            hintStyle: TextStyle(
                              color: Colors.grey,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),

                      // 🔄 Search Results
                      if (_showSuggestions)
                        ValueListenableBuilder<List<SearchResult>>(
                          valueListenable: cubitX.autoSearchListNotifier,
                          builder: (context, list, _) {
                            if (_controller.text.isEmpty) {
                              return const SizedBox.shrink();
                            }

                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.1),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ConstrainedBox(
                                    constraints: const BoxConstraints(
                                      maxHeight: 100,
                                    ),
                                    child: list.isEmpty
                                        ? const SizedBox()
                                        : ListView.builder(
                                            shrinkWrap: true,
                                            physics:
                                                const AlwaysScrollableScrollPhysics(),
                                            itemCount: list.length,
                                            itemBuilder: (context, index) {
                                              final result = list[index];
                                              return InkWell(
                                                onTap: () {
                                                  _controller.text = result
                                                      .valueToDisplay
                                                      .toString();
                                                  _controller.selection =
                                                      TextSelection.fromPosition(
                                                        TextPosition(
                                                          offset: _controller
                                                              .text
                                                              .length,
                                                        ),
                                                      );
                                                  FocusScope.of(
                                                    context,
                                                  ).unfocus();

                                                  if (result.searchArray!.query
                                                      is List) {
                                                    searchQueryHotel =
                                                        List<String>.from(
                                                          result
                                                              .searchArray!
                                                              .query,
                                                        );
                                                  } else if (result
                                                          .searchArray!
                                                          .query
                                                      is String) {
                                                    searchQueryHotel = [
                                                      result.searchArray!.query
                                                          .toString(),
                                                    ];
                                                  }

                                                  setState(() {
                                                    _showSuggestions = false;
                                                  });
                                                },
                                                child: _buildResultTile(result),
                                              );
                                            },
                                          ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),

                      // Always show booking details
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 16.0,
                          right: 16,
                          bottom: 10,
                        ),
                        child: _buildBookingDetails(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(left: 8.0, top: 10),
            child: Text(
              "On Stay Hotel",
              style: GoogleFonts.poppins(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),

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
                  onRefresh: () async => cubit.refresh(),
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
