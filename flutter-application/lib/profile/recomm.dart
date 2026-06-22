import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gardproject/models/recommendation_model.dart';
import 'package:gardproject/profile/result.dart';
import 'package:gardproject/service/recommendation_service.dart';

enum RecommendationTab {
  all,
  irrigation,
  fertilization,
  disease,
}

class RecommendationsScreen extends StatefulWidget {
  final String? farmId;

  const RecommendationsScreen({
    super.key,
    this.farmId,
  });

  @override
  State<RecommendationsScreen> createState() => _RecommendationsScreenState();
}

class _RecommendationsScreenState extends State<RecommendationsScreen> {
  final RecommendationService _service = RecommendationService();

  RecommendationTab selectedTab = RecommendationTab.all;

  bool isLoading = true;
  String? errorMessage;
  List<RecommendationModel> recommendations = [];

  @override
  void initState() {
    super.initState();
    _loadRecommendations();
  }

  String _getScreenTitle() {
    switch (selectedTab) {
      case RecommendationTab.all:
        return 'Recommendations';
      case RecommendationTab.irrigation:
        return 'Irrigation';
      case RecommendationTab.fertilization:
        return 'Fertilization';
      case RecommendationTab.disease:
        return 'Disease';
    }
  }

  String? _mapTabToApiType(RecommendationTab tab) {
    switch (tab) {
      case RecommendationTab.all:
        return null;
      case RecommendationTab.irrigation:
        return 'irrigation';
      case RecommendationTab.fertilization:
        return 'fertilization';
      case RecommendationTab.disease:
        return 'disease';
    }
  }

  Future<void> _loadRecommendations() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final result = await _service.getRecommendations(
        type: _mapTabToApiType(selectedTab),
        status: 'pending',
        farmId: widget.farmId,
      );

      if (!mounted) return;

      setState(() {
        recommendations = result;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage = e.toString();
      });
    } finally {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _markAsDone(String recommendationId) async {
    try {
      await _service.updateRecommendationStatus(
        id: recommendationId,
        status: 'done',
      );

      if (!mounted) return;

      setState(() {
        recommendations.removeWhere((item) => item.id == recommendationId);
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Update failed: $e'),
        ),
      );
    }
  }

  void _changeTab(RecommendationTab tab) {
    setState(() {
      selectedTab = tab;
    });

    _loadRecommendations();
  }

  String _formatDate(String? rawDate) {
    if (rawDate == null || rawDate.isEmpty) return 'No deadline';

    try {
      final date = DateTime.parse(rawDate).toLocal();
      return '${date.day}/${date.month}/${date.year}';
    } catch (_) {
      return rawDate;
    }
  }
bool _isNoIrrigation(RecommendationModel item) {
  final text = '${item.title} ${item.description} ${item.action}'.toLowerCase();

  return item.type == 'irrigation' &&
      (text.contains('no irrigation') ||
          text.contains('not needed') ||
          text.contains('no need'));
}
 Widget _getTypeIcon(RecommendationModel item) {
  if (_isNoIrrigation(item)) {
    return SvgPicture.asset(
      'images/healthicons--yes-outline.svg',
      width: 25,
      height: 25,
      colorFilter: const ColorFilter.mode(
        Color(0xFFB5DD47),
        BlendMode.srcIn,
      ),
    );
  }

  switch (item.type) {
    case 'irrigation':
      return 
      Icon(
       Icons.eco_outlined,color: Color(0xFFB5DD47),size: 26,);

    case 'fertilization':
      return  Icon(
      Icons.eco_outlined,color: Color(0xFFB5DD47),size: 26,);

    case 'disease':
      return    const Icon(
             Icons.shield_outlined,
              size: 24,
             color: Color(0xFFC94A49),
            );
    

    default:
      return SvgPicture.asset(
        'images/healthicons--yes-outline.svg',
        width: 25,
        height: 25,
      );
  }
}

  Color _getTypeIconColor(String type) {
    if (type == 'disease') {
      return const Color(0xFFC94A49);
    }
    return const Color(0xFFB5DD47);
  }

  Widget _buildPriorityBadge(
  String priority, {
  bool isNoIrrigation = false,
}) {
  final value = isNoIrrigation ? 'low' : priority.toLowerCase();

  Color bgColor;
  Color textColor;

  switch (value) {
    case 'high':
      bgColor = const Color(0xFFF0A8A7);
      textColor = Colors.white;
      break;
    case 'medium':
      bgColor = const Color(0xFFF3DEAA);
      textColor = const Color(0xFF8A6A12);
      break;
    default:
      bgColor = const Color(0xFFE5E8DD);
      textColor = const Color(0xFF7E8472);
  }

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
    decoration: BoxDecoration(
      color: bgColor,
      borderRadius: BorderRadius.circular(30),
    ),
    child: Text(
      value.toUpperCase(),
      style: TextStyle(
        color: textColor,
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.3,
      ),
    ),
  );
}
  Widget _buildTopChip({
    required String text,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFB5DD47) : Colors.white,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoBox({
    required String label,
    required String value,
  }) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(
          fontSize: 16.5,
          color: Color(0xFF444444),
          height: 1.4,
        ),
        children: [
          TextSpan(
            text: '$label: ',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          TextSpan(text: value),
        ],
      ),
    );
  }

  Widget _buildActionBox(String action) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFDCE5CD),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 7,
            height: 7,
            margin: const EdgeInsets.only(top: 9, left: 5),
            decoration: const BoxDecoration(
              color: Color(0xFFB5DD47),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF39412D),
                  height: 1.5,
                ),
                children: [
                  const TextSpan(
                    text: 'Action: ',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  TextSpan(text: action),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleSection(RecommendationModel item) {
    if (item.details.schedule.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        const Text(
          'Schedule',
          style: TextStyle(
            fontSize: 16.5,
            fontWeight: FontWeight.w700,
            color: Color(0xFF2A2A2A),
          ),
        ),
        const SizedBox(height: 8),
        ...item.details.schedule.map(
          (step) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '•  ',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF6A6A6A),
                  ),
                ),
                Expanded(
                  child: Text(
                    '${step.day}: ${step.action}',
                    style: const TextStyle(
                      fontSize: 15.5,
                      color: Color(0xFF6A6A6A),
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNotesSection(RecommendationModel item) {
    if (item.details.notes.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        const Text(
          'Notes',
          style: TextStyle(
            fontSize: 16.5,
            fontWeight: FontWeight.w700,
            color: Color(0xFF2A2A2A),
          ),
        ),
        const SizedBox(height: 8),
        ...item.details.notes.map(
          (note) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '•  ',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF6A6A6A),
                  ),
                ),
                Expanded(
                  child: Text(
                    note,
                    style: const TextStyle(
                      fontSize: 15.5,
                      color: Color(0xFF6A6A6A),
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMetaSection(RecommendationModel item) {
    final rows = <Widget>[];

    if (item.meta.soilMoisture != null) {
      rows.add(_buildMetaRow('Soil Moisture', '${item.meta.soilMoisture}%'));
    }

    if (item.meta.soilType != null && item.meta.soilType!.isNotEmpty) {
      rows.add(_buildMetaRow('Soil Type', item.meta.soilType!));
    }

    if (item.meta.growthStage != null && item.meta.growthStage!.isNotEmpty) {
      rows.add(_buildMetaRow('Growth Stage', item.meta.growthStage!));
    }

    if (item.meta.scanDisease != null && item.meta.scanDisease!.isNotEmpty) {
      rows.add(_buildMetaRow('Detected Disease', item.meta.scanDisease!));
    }

    if (item.meta.scanConfidence != null) {
      rows.add(_buildMetaRow('Confidence', '${item.meta.scanConfidence}%'));
    }

    if (rows.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F8F8),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(children: rows),
        ),
      ],
    );
  }

  Widget _buildMetaRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14.5,
                color: Color(0xFF6D6D6D),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 14.5,
                color: Color(0xFF2D2D2D),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard(RecommendationModel item) {
    final isDisease = item.type == 'disease';
    final isNoIrrigation = _isNoIrrigation(item);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(35),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _getTypeIcon(item),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2A2A2A),
                  ),
                ),
              ),
              _buildPriorityBadge(
  item.priority,
  isNoIrrigation: isNoIrrigation,
),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            item.description,
            style: const TextStyle(
              fontSize: 17.5,
              color: Color(0xFF2D2D2D),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF1EFEF),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoBox(label: 'Reason', value: item.reason),
                const SizedBox(height: 12),
                _buildActionBox(item.action),
              ],
            ),
          ),
          _buildScheduleSection(item),
          _buildNotesSection(item),
          _buildMetaSection(item),
          const SizedBox(height: 10),
          Row(
            children: [
              if (isDisease)
                OutlinedButton(
                  onPressed: () {
                    if (item.meta.scanId == null ||
                        item.meta.scanId!.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('No scan result linked'),
                        ),
                      );
                      return;
                    }

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ScanResultScreen(
                          scanId: item.meta.scanId!,
                        ),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 8,
                    ),
                    side: const BorderSide(color: Color(0xFFD7D2D2)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    backgroundColor: Colors.white,
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 21,
                        color: Color(0xFF3A3A3A),
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Details',
                        style: TextStyle(
                          color: Color(0xFF2F2F2F),
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              const Spacer(),
              ElevatedButton(
                onPressed: () => _markAsDone(item.id),
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: const Color(0xFFB5DD47),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: const Text(
                  'Done',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Row(
              children: [
                const Icon(
                  Icons.access_time_rounded,
                  size: 20,
                  color: Color(0xFF8C8C8C),
                ),
                const SizedBox(width: 6),
                Text(
                  _formatDate(item.validUntil),
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 15.5,
                    color: Color(0xFF8C8C8C),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFFB5DD47),
        ),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 42,
                color: Colors.redAccent,
              ),
              const SizedBox(height: 12),
              Text(
                errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15.5,
                  color: Color(0xFF444444),
                ),
              ),
              const SizedBox(height: 14),
              ElevatedButton(
                onPressed: _loadRecommendations,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB5DD47),
                  foregroundColor: Colors.black,
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (recommendations.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadRecommendations,
        child: ListView(
          children: const [
            SizedBox(height: 300),
            Center(
              child: Text(
                'No recommendations found',
                style: TextStyle(
                  fontSize: 16.5,
                  color: Color(0xFF666666),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadRecommendations,
      child: ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: recommendations.length,
        itemBuilder: (context, index) {
          final item = recommendations[index];

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildRecommendationCard(item),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F4F4),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getScreenTitle(),
                style: const TextStyle(
                  fontSize: 31,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildTopChip(
                      text: 'All',
                      isSelected: selectedTab == RecommendationTab.all,
                      onTap: () => _changeTab(RecommendationTab.all),
                    ),
                    const SizedBox(width: 6),
                    _buildTopChip(
                      text: 'Irrigation',
                      isSelected: selectedTab == RecommendationTab.irrigation,
                      onTap: () => _changeTab(RecommendationTab.irrigation),
                    ),
                    const SizedBox(width: 6),
                    _buildTopChip(
                      text: 'Fertilization',
                      isSelected:
                          selectedTab == RecommendationTab.fertilization,
                      onTap: () => _changeTab(RecommendationTab.fertilization),
                    ),
                    const SizedBox(width: 6),
                    _buildTopChip(
                      text: 'Disease',
                      isSelected: selectedTab == RecommendationTab.disease,
                      onTap: () => _changeTab(RecommendationTab.disease),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: _buildBody(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}