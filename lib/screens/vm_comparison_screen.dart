import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class VMComparisonScreen extends StatefulWidget {
  const VMComparisonScreen({super.key});

  @override
  State<VMComparisonScreen> createState() => _VMComparisonScreenState();
}

class _VMComparisonScreenState extends State<VMComparisonScreen> {
  final List<Map<String, dynamic>> _comparisonVMs = [];
  final int maxVMs = 3;

  // Common presets for quick comparison
  final List<Map<String, dynamic>> quickPresets = [
    {'name': 'Micro', 'vcpus': 1, 'memory': 1, 'storage': 50},
    {'name': 'Small', 'vcpus': 2, 'memory': 8, 'storage': 100},
    {'name': 'Medium', 'vcpus': 4, 'memory': 16, 'storage': 200},
    {'name': 'Large', 'vcpus': 8, 'memory': 32, 'storage': 500},
    {'name': 'X-Large', 'vcpus': 16, 'memory': 64, 'storage': 1000},
  ];

  @override
  Widget build(BuildContext context) {
    final isWeb = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF667eea), Color(0xFF764ba2), Color(0xFFf093fb)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(context),
              
              // Main Content
              Expanded(
                child: SingleChildScrollView(
                  child: Center(
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: isWeb ? 1400 : double.infinity,
                      ),
                      padding: EdgeInsets.all(isWeb ? 32 : 20),
                      child: Column(
                        children: [
                          // Quick Presets
                          _buildQuickPresets(),
                          const SizedBox(height: 32),
                          
                          // Comparison Grid
                          if (_comparisonVMs.isNotEmpty)
                            _buildComparisonGrid(isWeb)
                          else
                            _buildEmptyState(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          ),
          const SizedBox(width: 12),
          const Icon(Icons.compare_rounded, color: Colors.white, size: 32),
          const SizedBox(width: 12),
          const Text(
            'VM Comparison',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          if (_comparisonVMs.isNotEmpty)
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _comparisonVMs.clear();
                });
              },
              icon: const Icon(Icons.clear_all, color: Colors.white),
              label: const Text(
                'Clear All',
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildQuickPresets() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.speed_rounded, color: Color(0xFF667eea)),
              const SizedBox(width: 8),
              const Text(
                'Quick Compare',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              Text(
                '${_comparisonVMs.length}/$maxVMs selected',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: quickPresets.map((preset) {
              final isSelected = _comparisonVMs.any((vm) =>
                  vm['vcpus'] == preset['vcpus'] &&
                  vm['memory'] == preset['memory']);
              
              return InkWell(
                onTap: () => _toggleVM(preset),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? const LinearGradient(
                            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                          )
                        : null,
                    color: isSelected ? null : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? Colors.transparent : Colors.grey.shade300,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isSelected ? Icons.check_circle : Icons.add_circle_outline,
                        color: isSelected ? Colors.white : const Color(0xFF667eea),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        preset['name'],
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${preset['vcpus']}vCPU • ${preset['memory']}GB',
                        style: TextStyle(
                          fontSize: 12,
                          color: isSelected
                              ? Colors.white.withOpacity(0.9)
                              : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  void _toggleVM(Map<String, dynamic> preset) async {
    final exists = _comparisonVMs.any((vm) =>
        vm['vcpus'] == preset['vcpus'] && vm['memory'] == preset['memory']);

    if (exists) {
      setState(() {
        _comparisonVMs.removeWhere((vm) =>
            vm['vcpus'] == preset['vcpus'] && vm['memory'] == preset['memory']);
      });
    } else if (_comparisonVMs.length < maxVMs) {
      // Fetch prediction for this VM
      await _fetchPrediction(preset);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Maximum $maxVMs VMs can be compared at once'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  Future<void> _fetchPrediction(Map<String, dynamic> preset) async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.1.12:8000/predict/simplified'), // Change YOUR_NEW_IP to your actual IP from ipconfig
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'vcpus': preset['vcpus'].toDouble(),
          'memory_gb': preset['memory'].toDouble(),
          'boot_disk_gb': preset['storage'].toDouble(),
          'gpu_count': 0,
          'gpu_model': 'none',
          'usage_hours_month': 730,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _comparisonVMs.add({
            'name': preset['name'],
            'vcpus': preset['vcpus'],
            'memory': preset['memory'],
            'storage': preset['storage'],
            'prediction': data,
          });
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error fetching prediction: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(
            Icons.compare_arrows_rounded,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'No VMs Selected',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select VMs from the presets above to compare',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonGrid(bool isWeb) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isWeb ? _comparisonVMs.length : 1,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: isWeb ? 0.85 : 1.2,
      ),
      itemCount: _comparisonVMs.length,
      itemBuilder: (context, index) {
        return _buildVMCard(_comparisonVMs[index]);
      },
    );
  }

  Widget _buildVMCard(Map<String, dynamic> vm) {
    final prediction = vm['prediction'];
    final regression = prediction['regression'];
    final classification = prediction['classification'];
    final clustering = prediction['clustering'];
    final sentiment = prediction['sentiment'];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF667eea), Color(0xFF764ba2)],
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                Text(
                  vm['name'],
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${vm['vcpus']} vCPUs • ${vm['memory']} GB RAM',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Cost
                  _buildInfoRow(
                    'Monthly Cost',
                    regression['monthly_cost_formatted'],
                    Icons.attach_money,
                    Colors.green,
                  ),
                  const Divider(height: 24),
                  
                  // Category
                  _buildInfoRow(
                    'Price Category',
                    classification['category'],
                    Icons.category,
                    _getCategoryColor(classification['category']),
                  ),
                  const Divider(height: 24),
                  
                  // Cluster
                  _buildInfoRow(
                    'VM Cluster',
                    'Group ${clustering['cluster']}',
                    Icons.groups,
                    const Color(0xFF764ba2),
                  ),
                  
                  // Sentiment
                  if (sentiment != null) ...[
                    const Divider(height: 24),
                    _buildSentimentBadge(sentiment),
                  ],
                ],
              ),
            ),
          ),
          
          // Remove button
          TextButton.icon(
            onPressed: () {
              setState(() {
                _comparisonVMs.remove(vm);
              });
            },
            icon: const Icon(Icons.close, color: Colors.red),
            label: const Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSentimentBadge(Map<String, dynamic> sentiment) {
    final sentimentValue = sentiment['sentiment'] ?? 'neutral';
    Color color;
    IconData icon;
    
    switch (sentimentValue.toLowerCase()) {
      case 'positive':
        color = Colors.green;
        icon = Icons.sentiment_satisfied;
        break;
      case 'negative':
        color = Colors.orange;
        icon = Icons.sentiment_dissatisfied;
        break;
      default:
        color = Colors.blue;
        icon = Icons.sentiment_neutral;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 2),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              sentimentValue.toUpperCase(),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
          Text(
            '${(sentiment['confidence'] * 100).toStringAsFixed(0)}%',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
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
        return Colors.grey;
    }
  }
}

