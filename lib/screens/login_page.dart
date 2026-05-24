import 'package:flutter/material.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  // ── GSV credentials (password 0000 for all) ──────────────────────────────
  static const String _emailSuffix = '@gsv.ac.in';
  static const String _universalPassword = '0000';

  // Admin email for demo
  static const String _adminEmail = 'admin@gsv.ac.in';

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeIn);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.18),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    await Future.delayed(const Duration(milliseconds: 1500));

    if (!mounted) return;

    final email = _emailController.text.trim().toLowerCase();
    final password = _passwordController.text;

    if (email.endsWith(_emailSuffix) && password == _universalPassword) {
      final isAdmin = email == _adminEmail;
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, animation, __) => HomePage(isAdmin: isAdmin, userEmail: email),
          transitionsBuilder: (_, animation, __, child) => FadeTransition(
            opacity: animation,
            child: child,
          ),
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage =
            'Invalid credentials. Use your @gsv.ac.in email and password 0000.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF060818),
              Color(0xFF0D1B3E),
              Color(0xFF112240),
              Color(0xFF0A2342),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 36),
                      _buildFormCard(),
                      const SizedBox(height: 20),
                      _buildDemoHint(),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // College Logo placeholder
       Container(
  width: 100,
  height: 100,
  decoration: BoxDecoration(
    shape: BoxShape.circle,
    border: Border.all(color: const Color(0xFF42A5F5), width: 2.5),
    boxShadow: [
      BoxShadow(
        color: const Color(0xFF1565C0).withValues(alpha: 0.6),
        blurRadius: 32,
        spreadRadius: 4,
      ),
    ],
  ),
  clipBehavior: Clip.antiAlias,
  child: Image.asset(
    'assets/images/gsv_logo.jpg',
    fit: BoxFit.cover,
  ),
),
        const SizedBox(height: 18),
        const Text(
          'GATI SHAKTI',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w900,
            letterSpacing: 5,
          ),
        ),
        const Text(
          'VISHWAVIDYALAYA',
          style: TextStyle(
            color: Color(0xFF42A5F5),
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 3.5,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF1565C0).withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF42A5F5).withValues(alpha: 0.4)),
          ),
          child: const Text(
            '🏆  SPORTS COMMUNITY',
            style: TextStyle(
              color: Color(0xFF90CAF9),
              fontSize: 11,
              letterSpacing: 2,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome Back 👋',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              'Sign in with your GSV student account',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 28),

            // ── Email field with overlay hint ─────────────────────────────
            _buildLabel('Email Address'),
            const SizedBox(height: 8),
            _buildEmailField(),
            const SizedBox(height: 20),

            // ── Password field ────────────────────────────────────────────
            _buildLabel('Password'),
            const SizedBox(height: 8),
            _buildPasswordField(),

            // ── Error message ─────────────────────────────────────────────
            if (_errorMessage != null) ...[
              const SizedBox(height: 14),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFE94560).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: const Color(0xFFE94560).withValues(alpha: 0.4)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline,
                        color: Color(0xFFE94560), size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(
                            color: Color(0xFFE94560), fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 28),

            // ── Login Button ──────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1565C0),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor:
                      const Color(0xFF1565C0).withValues(alpha: 0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 8,
                  shadowColor: const Color(0xFF1565C0).withValues(alpha: 0.5),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'SIGN IN',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      validator: (v) {
        if (v == null || v.trim().isEmpty) return 'Email is required';
        if (!v.trim().toLowerCase().endsWith('@gsv.ac.in')) {
          return 'Use your @gsv.ac.in email address';
        }
        return null;
      },
      decoration: InputDecoration(
        hintText: 'yourname@gsv.ac.in',
        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.28)),
        prefixIcon:
            const Icon(Icons.email_outlined, color: Colors.white38, size: 20),
        // Overlay suffix showing the domain
        suffixIcon: Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF1565C0).withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                      color: const Color(0xFF42A5F5).withValues(alpha: 0.4)),
                ),
                child: const Text(
                  '@gsv.ac.in',
                  style: TextStyle(
                    color: Color(0xFF90CAF9),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.06),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              BorderSide(color: Colors.white.withValues(alpha: 0.12)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: Color(0xFF42A5F5), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: Color(0xFFE94560), width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: Color(0xFFE94560), width: 1.5),
        ),
        errorStyle:
            const TextStyle(color: Color(0xFFE94560), fontSize: 11),
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      validator: (v) {
        if (v == null || v.isEmpty) return 'Password is required';
        return null;
      },
      decoration: InputDecoration(
        hintText: '••••',
        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.25)),
        prefixIcon:
            const Icon(Icons.lock_outline, color: Colors.white38, size: 20),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            color: Colors.white38,
            size: 20,
          ),
          onPressed: () =>
              setState(() => _obscurePassword = !_obscurePassword),
        ),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.06),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              BorderSide(color: Colors.white.withValues(alpha: 0.12)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: Color(0xFF42A5F5), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: Color(0xFFE94560), width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: Color(0xFFE94560), width: 1.5),
        ),
        errorStyle:
            const TextStyle(color: Color(0xFFE94560), fontSize: 11),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.white.withValues(alpha: 0.75),
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildDemoHint() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1565C0).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: const Color(0xFF42A5F5).withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Color(0xFF42A5F5), size: 16),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Demo Credentials',
                  style: TextStyle(
                    color: Color(0xFF42A5F5),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Student: student@gsv.ac.in  |  Password: 0000\nAdmin:   admin@gsv.ac.in      |  Password: 0000',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.55),
                    fontSize: 11,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
