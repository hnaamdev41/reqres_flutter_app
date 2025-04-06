import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/user_card.dart';
import 'user_add_screen.dart';
import 'user_edit_screen.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({Key? key}) : super(key: key);

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  final TextEditingController _searchController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    // Fetch users when the screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserProvider>(context, listen: false).fetchUsers();
    });
    
    _searchController.addListener(_onSearchChanged);
  }
  
  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }
  
  void _onSearchChanged() {
    Provider.of<UserProvider>(context, listen: false)
        .setSearchQuery(_searchController.text);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        authProvider.logout();
                      },
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search',
                hintText: 'Search by name or email',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
              ),
            ),
          ),
          Expanded(
            child: _buildUserList(userProvider),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const UserAddScreen(),
            ),
          ).then((_) {
            // Refresh the list when returning from add screen
            userProvider.fetchUsers();
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildUserList(UserProvider userProvider) {
    switch (userProvider.status) {
      case UserStatus.loading:
        return const LoadingWidget(message: 'Loading users...');
        
      case UserStatus.loaded:
        if (userProvider.users.isEmpty) {
          return const Center(
            child: Text(
              'No users found',
              style: TextStyle(fontSize: 18.0),
            ),
          );
        }
        
        return RefreshIndicator(
          onRefresh: () => userProvider.fetchUsers(),
          child: ListView.builder(
            itemCount: userProvider.users.length,
            itemBuilder: (context, index) {
              final user = userProvider.users[index];
              return UserCard(
                user: user,
                onEdit: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserEditScreen(user: user),
                    ),
                  ).then((_) {
                    // Refresh the list when returning from edit screen
                    userProvider.fetchUsers();
                  });
                },
                onDelete: () async {
                  final success = await userProvider.deleteUser(user.id!);
                  
                  if (success) {
                    Fluttertoast.showToast(
                      msg: 'User deleted successfully',
                      backgroundColor: Colors.green,
                    );
                  } else {
                    Fluttertoast.showToast(
                      msg: userProvider.errorMessage ?? 'Failed to delete user',
                      backgroundColor: Colors.red,
                    );
                  }
                },
              );
            },
          ),
        );
        
      case UserStatus.error:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 60,
              ),
              const SizedBox(height: 16),
              Text(
                userProvider.errorMessage ?? 'An error occurred',
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => userProvider.fetchUsers(),
                child: const Text('Retry'),
              ),
            ],
          ),
        );
        
      default:
        return const Center(child: Text('Nothing to display'));
    }
  }
}