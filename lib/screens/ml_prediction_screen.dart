import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'feedback_screen.dart';

class MLPredictionScreen extends StatefulWidget {
  final double? initialVCPUs;
  final double? initialMemory;
  final double? initialStorage;
  
  const MLPredictionScreen({
    super.key,
    this.initialVCPUs,
    this.initialMemory,
    this.initialStorage,
  });

  @override
  State<MLPredictionScreen> createState() => _MLPredictionScreenState();
}

class _MLPredictionScreenState extends State<MLPredictionScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers for input fields
  final _vcpusController = TextEditingController();
  final _memoryController = TextEditingController();
  final _storageController = TextEditingController();
  final _gpuCountController = TextEditingController();
  final _usageHoursController = TextEditingController();
  
  // GPU model dropdown
  String _selectedGpuModel = 'None';
  
  bool _isLoading = false;
  Map<String, dynamic>? _prediction;
  List<dynamic>? _recommendations;
  bool _isLoadingRecommendations = false;
  
  // API endpoint - Your PC's IP address
  String apiUrl = "http://192.168.1.12:8000"; // Change YOUR_NEW_IP to your actual IP from ipconfig
  
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    _fadeController.forward();
    
    // Set initial values if provided
    if (widget.initialVCPUs != null) {
      _vcpusController.text = widget.initialVCPUs!.toStringAsFixed(0);
    }
    if (widget.initialMemory != null) {
      _memoryController.text = widget.initialMemory!.toStringAsFixed(0);
    }
    if (widget.initialStorage != null) {
      _storageController.text = widget.initialStorage!.toStringAsFixed(0);
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _vcpusController.dispose();
    _memoryController.dispose();
    _storageController.dispose();
    _gpuCountController.dispose();
    _usageHoursController.dispose();
    super.dispose();
  }

  Future<void> _makePrediction() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _prediction = null;
    });

    try {
      // Prepare features (adjust based on your actual model features)
      final features = [
        double.parse(_vcpusController.text),
        double.parse(_memoryController.text),
        double.parse(_storageController.text),
        // Add more features as needed
      ];

      final response = await http.post(
        Uri.parse('$apiUrl/predict/simplified'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'vcpus': double.parse(_vcpusController.text),
          'memory_gb': double.parse(_memoryController.text),
          'boot_disk_gb': double.parse(_storageController.text),
          'gpu_count': _gpuCountController.text.isEmpty ? 0 : double.parse(_gpuCountController.text),
          'gpu_model': _selectedGpuModel.toLowerCase(),
          'usage_hours_month': _usageHoursController.text.isEmpty ? 730 : double.parse(_usageHoursController.text),
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          _prediction = json.decode(response.body);
        });
        
        // Get recommendations
        await _getRecommendations();
      } else {
        _showError('Prediction failed: ${response.statusCode}');
      }
    } catch (e) {
      _showError('Connection error: $e\n\nMake sure:\n1. Server is running\n2. Phone and PC are on same Wi-Fi\n3. IP address is correct');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _getRecommendations() async {
    setState(() => _isLoadingRecommendations = true);
    
    try {
      print('🔍 Fetching recommendations...');
      final response = await http.post(
        Uri.parse('$apiUrl/recommend'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'vcpus': double.parse(_vcpusController.text),
          'memory_gb': double.parse(_memoryController.text),
          'boot_disk_gb': double.parse(_storageController.text),
          'gpu_count': _gpuCountController.text.isEmpty ? 0 : double.parse(_gpuCountController.text),
          'gpu_model': _selectedGpuModel.toLowerCase(),
          'usage_hours_month': _usageHoursController.text.isEmpty ? 730 : double.parse(_usageHoursController.text),
        }),
      );

      print('📡 Recommendation response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('📦 Received data: ${data.toString()}');
        print('✅ Recommendations count: ${data['recommendations']?.length ?? 0}');
        
        setState(() {
          _recommendations = data['recommendations'];
        });
        
        if (_recommendations == null || _recommendations!.isEmpty) {
          print('⚠️ No recommendations returned');
        } else {
          print('✅ ${_recommendations!.length} recommendations loaded');
        }
      } else {
        print('❌ Recommendation request failed: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      // Recommendations are optional, silently fail
      print('❌ Recommendations error: $e');
    } finally {
      setState(() => _isLoadingRecommendations = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
      ),
    );
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
              Color(0xFF667eea),
              Color(0xFF764ba2),
              Color(0xFFf093fb),
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new_rounded,
                              color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'GCP VM Pricing',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.2),
                              offset: const Offset(0, 2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Main Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // Info Card
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.95),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.cloud_outlined,
                                    color: Colors.white,
                                    size: 32,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'ML Powered Prediction',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        'Enter VM specs to get cost estimate',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Input Fields
                          _buildInputField(
                            controller: _vcpusController,
                            label: 'vCPUs',
                            icon: Icons.memory_rounded,
                            hint: 'e.g., 2',
                          ),
                          const SizedBox(height: 16),
                          
                          _buildInputField(
                            controller: _memoryController,
                            label: 'Memory (GB)',
                            icon: Icons.storage_rounded,
                            hint: 'e.g., 8',
                          ),
                          const SizedBox(height: 16),
                          
                          _buildInputField(
                            controller: _storageController,
                            label: 'Storage (GB)',
                            icon: Icons.storage_rounded,
                            hint: 'e.g., 100',
                          ),
                          const SizedBox(height: 16),
                          
                          _buildInputField(
                            controller: _gpuCountController,
                            label: 'GPU Count (Optional)',
                            icon: Icons.video_settings_rounded,
                            hint: 'e.g., 0 (leave empty for 0)',
                            isRequired: false,
                          ),
                          const SizedBox(height: 16),
                          
                          // GPU Model Dropdown
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.95),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                              child: DropdownButtonFormField<String>(
                                value: _selectedGpuModel,
                                decoration: InputDecoration(
                                  labelText: 'GPU Model (Optional)',
                                  labelStyle: TextStyle(
                                    color: const Color(0xFF667eea).withOpacity(0.7),
                                    fontWeight: FontWeight.w500,
                                  ),
                                  prefixIcon: const Icon(
                                    Icons.settings_input_component_rounded,
                                    color: Color(0xFF667eea),
                                  ),
                                  border: InputBorder.none,
                                ),
                                style: const TextStyle(fontSize: 16, color: Colors.black87),
                                items: const [
                                  DropdownMenuItem(value: 'None', child: Text('None')),
                                  DropdownMenuItem(value: 'K80', child: Text('NVIDIA K80')),
                                  DropdownMenuItem(value: 'T4', child: Text('NVIDIA Tesla T4')),
                                  DropdownMenuItem(value: 'V100', child: Text('NVIDIA V100')),
                                  DropdownMenuItem(value: 'A100', child: Text('NVIDIA A100')),
                                  DropdownMenuItem(value: 'P4', child: Text('NVIDIA P4')),
                                  DropdownMenuItem(value: 'P100', child: Text('NVIDIA P100')),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    _selectedGpuModel = value!;
                                  });
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          _buildInputField(
                            controller: _usageHoursController,
                            label: 'Usage Hours/Month (Optional)',
                            icon: Icons.access_time_rounded,
                            hint: 'e.g., 730 (full month)',
                            isRequired: false,
                          ),
                          const SizedBox(height: 32),

                          // Predict Button
                          Container(
                            width: double.infinity,
                            height: 60,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF667eea).withOpacity(0.5),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: ElevatedButton.icon(
                              onPressed: _isLoading ? null : _makePrediction,
                              icon: _isLoading
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 3,
                                      ),
                                    )
                                  : const Icon(Icons.psychology_rounded,
                                      color: Colors.white),
                              label: Text(
                                _isLoading ? 'Predicting...' : 'Predict Cost',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 1,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),
                          ),

                          // Results
                          if (_prediction != null) ...[
                            const SizedBox(height: 32),
                            _buildResultsCard(),
                          ],
                          
                          // Similar VMs Recommendations - Always show after prediction
                          if (_prediction != null) ...[
                            const SizedBox(height: 24),
                            _buildRecommendationsSection(),
                            
                            // Feedback Button
                            const SizedBox(height: 24),
                            _buildFeedbackButton(),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
    bool isRequired = true,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        style: const TextStyle(fontSize: 16),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: TextStyle(
            color: const Color(0xFF667eea).withOpacity(0.7),
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Icon(icon, color: const Color(0xFF667eea)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(20),
        ),
        validator: (value) {
          if (isRequired) {
            if (value == null || value.isEmpty) {
              return 'Please enter a value';
            }
          }
          if (value != null && value.isNotEmpty && double.tryParse(value) == null) {
            return 'Please enter a valid number';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildResultsCard() {
    final regression = _prediction!['regression'];
    final classification = _prediction!['classification'];
    final clustering = _prediction!['clustering'];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.bar_chart_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              const Text(
                'Prediction Results',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Monthly Cost
          _buildResultRow(
            label: 'Monthly Cost',
            value: regression['monthly_cost_formatted'],
            icon: Icons.attach_money_rounded,
            color: Colors.green,
          ),
          const Divider(height: 32),

          // Price Category
          _buildResultRow(
            label: 'Price Category',
            value: classification['category'],
            icon: Icons.category_rounded,
            color: _getCategoryColor(classification['category']),
          ),
          const Divider(height: 32),

          // Cluster
          _buildResultRow(
            label: 'VM Cluster',
            value: 'Group ${clustering['cluster']}',
            icon: Icons.groups_rounded,
            color: const Color(0xFF764ba2),
          ),
          
          // Sentiment Analysis (if available)
          if (_prediction!.containsKey('sentiment')) ...[
            const Divider(height: 32),
            _buildSentimentRow(_prediction!['sentiment']),
          ],

          // Probabilities
          const SizedBox(height: 24),
          const Text(
            'Category Confidence',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          _buildProbabilityBar('Low', classification['probabilities']['Low']),
          const SizedBox(height: 8),
          _buildProbabilityBar('Medium', classification['probabilities']['Medium']),
          const SizedBox(height: 8),
          _buildProbabilityBar('High', classification['probabilities']['High']),
          
          // Recommendations
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF667eea).withOpacity(0.1),
                  const Color(0xFF764ba2).withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: const Color(0xFF667eea).withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.recommend_rounded,
                      color: const Color(0xFF667eea),
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Recommendations',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildRecommendation(
                  icon: Icons.lightbulb_outline_rounded,
                  text: 'This VM is in Cluster ${clustering['cluster']} with similar VMs',
                  color: const Color(0xFF764ba2),
                ),
                const SizedBox(height: 8),
                _buildRecommendation(
                  icon: _getCategoryIcon(classification['category']),
                  text: 'Price category: ${classification['category']} - ${_getCategoryAdvice(classification['category'])}',
                  color: _getCategoryColor(classification['category']),
                ),
                const SizedBox(height: 8),
                if (_prediction!['input_summary']['has_gpu'] == true)
                  _buildRecommendation(
                    icon: Icons.info_outline_rounded,
                    text: 'GPU detected: ${_prediction!['input_summary']['gpu_model'].toUpperCase()} - Consider sustained use discounts',
                    color: const Color(0xFFf093fb),
                  ),
                if (_prediction!['input_summary']['has_gpu'] == false)
                  _buildRecommendation(
                    icon: Icons.tips_and_updates_outlined,
                    text: 'No GPU selected - Good for general workloads',
                    color: Colors.green,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultRow({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProbabilityBar(String label, double probability) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            Text(
              '${(probability * 100).toStringAsFixed(1)}%',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: probability,
            minHeight: 8,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(_getCategoryColor(label)),
          ),
        ),
      ],
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'low':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'high':
        return Colors.red;
      default:
        return const Color(0xFF667eea);
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'low':
        return Icons.thumb_up_rounded;
      case 'medium':
        return Icons.balance_rounded;
      case 'high':
        return Icons.trending_up_rounded;
      default:
        return Icons.info_rounded;
    }
  }

  String _getCategoryAdvice(String category) {
    switch (category.toLowerCase()) {
      case 'low':
        return 'Cost-effective choice';
      case 'medium':
        return 'Balanced performance & cost';
      case 'high':
        return 'Premium performance tier';
      default:
        return 'Standard pricing';
    }
  }

  Widget _buildSentimentRow(Map<String, dynamic> sentiment) {
    // Get sentiment data
    final sentimentValue = sentiment['sentiment'] ?? 'neutral';
    final meaning = sentiment['meaning'] ?? 'Unknown';
    final valueScore = sentiment['value_score'] ?? 0.0;
    final confidence = sentiment['confidence'] ?? 0.0;
    
    // Colors and icons based on sentiment
    Color sentimentColor;
    IconData sentimentIcon;
    
    switch (sentimentValue.toLowerCase()) {
      case 'positive':
        sentimentColor = Colors.green;
        sentimentIcon = Icons.sentiment_satisfied_rounded;
        break;
      case 'negative':
        sentimentColor = Colors.orange;
        sentimentIcon = Icons.sentiment_dissatisfied_rounded;
        break;
      default:
        sentimentColor = Colors.blue;
        sentimentIcon = Icons.sentiment_neutral_rounded;
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(sentimentIcon, color: sentimentColor, size: 32),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Value Analysis',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    sentimentValue.toUpperCase(),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: sentimentColor,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: sentimentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: sentimentColor, width: 2),
              ),
              child: Text(
                '${(confidence * 100).toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: sentimentColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: sentimentColor.withOpacity(0.05),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: sentimentColor.withOpacity(0.2),
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: sentimentColor, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  meaning,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade800,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Value Score: ${valueScore.toStringAsFixed(3)}',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendation({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendationsSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.98),
            Colors.white.withOpacity(0.95),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF764ba2).withOpacity(0.2),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
        border: Border.all(
          color: Colors.white.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF764ba2), Color(0xFFf093fb)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF764ba2).withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.recommend_rounded,
                  color: Colors.white,
                  size: 26,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Similar VMs',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Powered by AI matching',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (_isLoadingRecommendations)
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                ),
            ],
          ),
          const SizedBox(height: 24),

          // Content
          if (_isLoadingRecommendations)
            _buildLoadingState()
          else if (_recommendations == null || _recommendations!.isEmpty)
            _buildEmptyState()
          else
            ..._recommendations!.asMap().entries.map((entry) {
              int index = entry.key;
              var rec = entry.value;
              return Column(
                children: [
                  if (index > 0) const SizedBox(height: 16),
                  _buildVMCard(rec, index + 1),
                ],
              );
            }).toList(),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            'Finding similar VMs...',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No similar VMs found',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your configuration is unique!',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildVMCard(Map<String, dynamic> rec, int rank) {
    final rankColors = [
      [const Color(0xFFFFD700), const Color(0xFFFFA500)], // Gold
      [const Color(0xFFC0C0C0), const Color(0xFF808080)], // Silver
      [const Color(0xFFCD7F32), const Color(0xFF8B4513)], // Bronze
    ];
    
    final cardGradient = rank <= 3 ? rankColors[rank - 1] : [const Color(0xFF667eea), const Color(0xFF764ba2)];
    
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            cardGradient[0].withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: cardGradient[0].withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: cardGradient[0].withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with rank badge and cost
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: cardGradient),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: cardGradient[0].withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      rank == 1 ? Icons.emoji_events : Icons.star,
                      color: Colors.white,
                      size: 18,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '#$rank',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      rec['monthly_cost_formatted'],
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF667eea),
                      ),
                    ),
                    Text(
                      'per month',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getCategoryColor(rec['category']).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _getCategoryColor(rec['category']),
                    width: 2,
                  ),
                ),
                child: Text(
                  rec['category'],
                  style: TextStyle(
                    color: _getCategoryColor(rec['category']),
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // VM Specs
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildSpecChip(Icons.memory_rounded, '${rec['vcpus']} vCPUs'),
              _buildSpecChip(Icons.storage_rounded, '${rec['memory_gb'].toStringAsFixed(0)} GB RAM'),
              _buildSpecChip(Icons.save_rounded, '${rec['storage_gb'].toStringAsFixed(0)} GB'),
              if (rec['gpu_count'] > 0)
                _buildSpecChip(Icons.video_settings_rounded, '${rec['gpu_count']} GPU'),
            ],
          ),
          
          // Machine type and region
          if (rec.containsKey('machine_type') || rec.containsKey('region')) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                if (rec.containsKey('machine_type')) ...[
                  Icon(Icons.computer_rounded, size: 14, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    rec['machine_type'],
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
                if (rec.containsKey('region') && rec.containsKey('machine_type'))
                  Text('  •  ', style: TextStyle(color: Colors.grey.shade600)),
                if (rec.containsKey('region')) ...[
                  Icon(Icons.location_on_outlined, size: 14, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      rec['region'],
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ],
          
          const SizedBox(height: 12),
          
          // Value indicators
          Row(
            children: [
              Icon(Icons.star_rounded, color: Colors.amber.shade600, size: 18),
              const SizedBox(width: 4),
              Text(
                'Value: ${rec['value_score'].toStringAsFixed(3)}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(width: 16),
              Icon(Icons.trending_up_rounded, color: Colors.green.shade600, size: 18),
              const SizedBox(width: 4),
              Text(
                '${(rec['similarity'] * 100).toStringAsFixed(1)}% Match',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSpecChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFF667eea).withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF667eea)),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackButton() {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFf093fb), Color(0xFF764ba2)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF764ba2).withOpacity(0.5),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FeedbackScreen(
                vmSpecs: {
                  'vcpus': double.parse(_vcpusController.text),
                  'memory_gb': double.parse(_memoryController.text),
                  'boot_disk_gb': double.parse(_storageController.text),
                  'gpu_count': _gpuCountController.text.isEmpty ? 0 : double.parse(_gpuCountController.text),
                  'gpu_model': _selectedGpuModel,
                },
                predictionResults: _prediction,
              ),
            ),
          );
        },
        icon: const Icon(Icons.feedback_outlined, color: Colors.white),
        label: const Text(
          'Give Feedback',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }
}

