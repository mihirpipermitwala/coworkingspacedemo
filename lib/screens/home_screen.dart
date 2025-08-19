import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/space_provider.dart';
import '../providers/notification_provider.dart';
import '../widgets/space_card.dart';
import '../widgets/search_bar.dart';
import '../widgets/filter_bottom_sheet.dart';
import 'map_screen.dart';
import 'my_bookings_screen.dart';
import 'notifications_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CoWorking Spaces'),
        actions: [
          Consumer<NotificationProvider>(
            builder: (context, notificationProvider, child) {
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NotificationsScreen(),
                        ),
                      );
                    },
                  ),
                  if (notificationProvider.unreadCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 14,
                          minHeight: 14,
                        ),
                        child: Text(
                          '${notificationProvider.unreadCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: const [_HomeTab(), MapScreen(), MyBookingsScreen()],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'My Bookings'),
        ],
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<SpaceProvider>(
      builder: (context, spaceProvider, child) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: CustomSearchBar(
                      onChanged: spaceProvider.searchSpaces,
                      hintText: 'Search by name, city, or location...',
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    icon: const Icon(Icons.filter_list),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (context) => const FilterBottomSheet(),
                      );
                    },
                  ),
                ],
              ),
            ),
            if (spaceProvider.isLoading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (spaceProvider.error != null)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error: ${spaceProvider.error}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => spaceProvider.loadSpaces(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              )
            else if (spaceProvider.spaces.isEmpty)
              const Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No coworking spaces found',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Try adjusting your search or filters',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => spaceProvider.loadSpaces(),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: spaceProvider.spaces.length,
                    itemBuilder: (context, index) {
                      return SpaceCard(space: spaceProvider.spaces[index]);
                    },
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
