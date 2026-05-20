import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'forgot_page.dart';
import 'signup_page.dart';
import 'home_page.dart';
import 'theme/app_theme.dart';
import 'widgets/custom_button.dart';

import 'services/auth_service.dart';
import 'services/product_service.dart';
import 'services/cart_service.dart';
import 'services/order_service.dart';
import 'services/user_service.dart';
import 'services/review_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  await _seedDatabaseIfNeeded();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const MyApp());
}

Future<void> _seedDatabaseIfNeeded() async {
  final firestore = FirebaseFirestore.instance;
  final productsSnapshot = await firestore.collection('products').limit(1).get();
  
  if (productsSnapshot.docs.isEmpty) {
    debugPrint('Database empty. Seeding initial products...');
    final products = [
      {
        'name': 'Elegant Evening Dress',
        'price': 120.0,
        'category': 'women',
        'subCategory': 'Recent',
        'images': ['lib/assets/images/women category/top/34.jpg'],
        'description': 'Beautiful evening dress for your special moments.',
        'size': ['S', 'M', 'L'],
        'colors': ['Red', 'Midnight Blue'],
        'stock': 12,
        'createdAt': FieldValue.serverTimestamp(),
        'views': 450,
        'isTrending': true,
      },
      {
        'name': 'Modern Woman Style',
        'price': 85.0,
        'category': 'women',
        'subCategory': 'New',
        'images': ['lib/assets/images/women category/top/35.jpg'],
        'description': 'Modern and stylish outfit for the contemporary woman.',
        'size': ['M', 'L'],
        'colors': ['Beige', 'Sand'],
        'stock': 15,
        'createdAt': FieldValue.serverTimestamp(),
        'views': 320,
        'isTrending': true,
      },
      {
        'name': 'Luxury Leather Handbag',
        'price': 180.0,
        'category': 'bags',
        'subCategory': 'Recent',
        'images': ['lib/assets/images/bag category/bag.png'],
        'description': 'Exquisite leather handbag with premium finish.',
        'size': ['Medium'],
        'colors': ['Tan', 'Black'],
        'stock': 5,
        'createdAt': FieldValue.serverTimestamp(),
        'views': 510,
        'isTrending': true,
      },
    ];

    for (var product in products) {
      await firestore.collection('products').add(product);
    }
    debugPrint('Seeding complete.');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(create: (_) => AuthService()),
        Provider<ProductService>(create: (_) => ProductService()),
        Provider<CartService>(create: (_) => CartService()),
        Provider<OrderService>(create: (_) => OrderService()),
        Provider<UserService>(create: (_) => UserService()),
        Provider<ReviewService>(create: (_) => ReviewService()),
      ],
      child: MaterialApp(
        title: 'MLAH Fashion Store',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: context.read<AuthService>().userChanges,
      builder: (context, snapshot) {
        if(snapshot.connectionState == ConnectionState.waiting) {
           return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if(snapshot.hasData && snapshot.data != null) {
          return const HomePage();
        }
        return const LoginPage();
      },
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  void _login() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter email and password')));
      return;
    }

    if (!email.contains('@')) {
      email = '$email@gmail.com';
    }

    setState(() => _isLoading = true);
    try {
      await context.read<AuthService>().signInWithEmailPassword(email, password);
    } on FirebaseAuthException catch (e) {
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message ?? 'Login failed')));
    } finally {
      if(mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 80),
              Text(
                'MLAH',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  color: AppTheme.primaryColor,
                  letterSpacing: 4,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'FASHION STORE',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 3,
                ),
              ),
              const SizedBox(height: 60),
              Text(
                'Welcome back',
                style: Theme.of(context).textTheme.displaySmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Sign in to your account to continue',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 40),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  hintText: 'Email address',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  hintText: 'Password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, size: 20),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ForgotPage())),
                  child: const Text('Forgot Password?'),
                ),
              ),
              const SizedBox(height: 32),
              CustomButton(
                label: 'Sign In',
                onPressed: _login,
                isLoading: _isLoading,
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text('OR', style: Theme.of(context).textTheme.labelSmall),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      label: 'Google',
                      isSecondary: true,
                      onPressed: () {},
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomButton(
                      label: 'Facebook',
                      isSecondary: true,
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 48),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account?"),
                  TextButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SignupPage())),
                    child: const Text('Sign up'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
