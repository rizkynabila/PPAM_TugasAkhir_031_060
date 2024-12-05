import 'package:flutter/material.dart';
import 'package:hive_ce/hive.dart';
import 'login.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isKesanSelected = true;
  String username = "Loading...";
  String email = "Loading...";
  late Box _prefsBox;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    _prefsBox = await Hive.openBox('prefsBox');
    setState(() {
      username = _prefsBox.get('username', defaultValue: 'Unknown User');
      email = _prefsBox.get('email', defaultValue: 'Unknown Email');
    });
  }

  Future<void> _logout() async {
    await _prefsBox.delete('isLoggedIn');
    await _prefsBox.delete('username');
    await _prefsBox.delete('email');

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Logout'),
          content: const Text('Apakah Anda yakin ingin keluar?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _logout();
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF18191A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF18191A),
        elevation: 0,
        title: const Text('Profile', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            onPressed: _showLogoutDialog,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const ProfileImage(),
            const SizedBox(height: 12.0),
            _buildProfileText(username, email),
            const SizedBox(height: 24.0),
            _buildButtonSwitch(),
            const SizedBox(height: 24.0),
            _buildContentBox(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileText(String username, String email) {
    return Column(
      children: [
        Text(
          username,
          style: const TextStyle(
              fontSize: 20.0, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 4.0),
        Text(
          email,
          style: const TextStyle(fontSize: 14.0, color: Colors.white70),
        ),
      ],
    );
  }

  Widget _buildButtonSwitch() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildSwitchButton('Kesan', true),
        const SizedBox(width: 16.0),
        _buildSwitchButton('Pesan', false),
      ],
    );
  }

  Widget _buildSwitchButton(String label, bool isKesan) {
    return Expanded(
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            isKesanSelected = isKesan;
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isKesanSelected == isKesan
              ? Colors.white
              : const Color(0xFF2E2E2E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
              color: isKesanSelected == isKesan ? Colors.black : Colors.white),
        ),
      ),
    );
  }

  Widget _buildContentBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: SingleChildScrollView(
        child: Text(
          isKesanSelected
              ? "Bagi saya pribadi, mata kuliah Pemrograman Aplikasi Mobile penuh dengan tantangan karena banyak hal baru yang harus dipelajari dalam kurun waktu yang menurut saya cukup singkat. Tapi dilain sisi, mata kuliah ini cukup menyenangkan berkat cara mengajar Pak Bagus yang santai dan mudah dipahami dalam menyampaikan materi. Pak Bagus juga memberi waktu kosong untuk belajar mandiri setelah beberapa pertemuan di kelas, hal ini cukup meringankan beban saya ditengah perkuliahan semester 5 yang MasyaAllah Tabarakallah."
              : "Tentunya terima kasih kepada Pak Bagus atas cara pembelajaran yang menyenangkan dan fleksibel. Sebagai saran, saya berharap apa ya bingung.",
          style: const TextStyle(fontSize: 14.0, color: Colors.black87),
        ),
      ),
    );
  }
}

class ProfileImage extends StatelessWidget {
  const ProfileImage({super.key});

  @override
  Widget build(BuildContext context) {
    return const CircleAvatar(
      radius: 50,
      backgroundImage: NetworkImage(
        'https://static.vecteezy.com/system/resources/previews/005/129/844/non_2x/profile-user-icon-isolated-on-white-background-eps10-free-vector.jpg',
      ),
    );
  }
}
