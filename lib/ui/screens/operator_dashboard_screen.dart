import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../viewmodels/route_viewmodel.dart';
import '../../viewmodels/exit_viewmodel.dart';
import '../../viewmodels/feedback_viewmodel.dart';
import '../../data/models/metro_models.dart';
import '../../data/models/exit_gate_model.dart';

/// Section 8: Operator/Admin Dashboard (Rajesh's View)
/// Allows managing stations, exits, and last-mile data.
class OperatorDashboardScreen extends StatefulWidget {
  const OperatorDashboardScreen({super.key});

  @override
  State<OperatorDashboardScreen> createState() => _OperatorDashboardScreenState();
}

class _OperatorDashboardScreenState extends State<OperatorDashboardScreen> {
  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Operator Dashboard',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Row(
            children: [
              _buildTab(0, 'Stations', Icons.account_tree),
              _buildTab(1, 'Exits', Icons.door_front_door),
              _buildTab(2, 'Bus Stops', Icons.bus_alert),
              _buildTab(3, 'Feedback', Icons.feedback),
            ],
          ),
        ),
      ),
      body: _buildBody(),
      floatingActionButton: _tabIndex == 1
          ? FloatingActionButton(
              onPressed: () => _showAddExitDialog(context),
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildTab(int index, String label, IconData icon) {
    final active = _tabIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _tabIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: active ? Colors.white : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: active ? Colors.white : Colors.white60, size: 20),
              const SizedBox(height: 4),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: active ? Colors.white : Colors.white60,
                  fontWeight: active ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    switch (_tabIndex) {
      case 0:
        return _buildStationsTab();
      case 1:
        return _buildExitsTab();
      case 2:
        return _buildBusStopsTab();
      case 3:
        return _buildFeedbackTab();
      default:
        return const Center(child: Text('Coming soon'));
    }
  }

  Widget _buildStationsTab() {
    final routeVM = context.watch<RouteViewModel>();
    final stations = routeVM.allStations;

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: stations.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final s = stations[i];
        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: s.lineId == 'purple' ? AppColors.primary : AppColors.accent,
              child: const Icon(Icons.train, color: Colors.white, size: 20),
            ),
            title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('ID: ${s.id} | Line: ${s.lineId.toUpperCase()}'),
            trailing: const Icon(Icons.edit, size: 18, color: Colors.grey),
          ),
        );
      },
    );
  }

  Widget _buildExitsTab() {
    final exitVM = context.watch<ExitViewModel>();
    final routeVM = context.watch<RouteViewModel>();
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: routeVM.allStations.length,
      itemBuilder: (context, i) {
        final s = routeVM.allStations[i];
        final exits = exitVM.getExitsForStation(s.id);
        
        return ExpansionTile(
          title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text('${exits.length} Exit Gates'),
          children: exits.map((e) => ListTile(
            title: Text('Gate ${e.gateNumber}: ${e.directionLabel}'),
            subtitle: Text('Landmarks: ${e.landmarks.join(", ")}'),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              onPressed: () {
                // Future: Implement delete
              },
            ),
          )).toList(),
        );
      },
    );
  }

  Widget _buildBusStopsTab() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bus_alert, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('Last-mile connectivity data sync...'),
        ],
      ),
    );
  }

  Widget _buildFeedbackTab() {
    final feedbackVM = context.watch<FeedbackViewModel>();
    final entries = feedbackVM.allEntries;

    if (entries.isEmpty) {
      return const Center(child: Text('No feedback entries yet.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: entries.length,
      itemBuilder: (context, i) {
        final e = entries[i];
        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.primary,
              child: Text(e.rating.toString(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            title: Text(e.category.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(e.message),
                if (e.stationName.isNotEmpty) Text('Station: ${e.stationName}', style: const TextStyle(fontStyle: FontStyle.italic)),
                Text(e.isAnonymous ? 'Anonymous' : 'User', style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              onPressed: () => feedbackVM.deleteEntry(e.id),
            ),
          ),
        );
      },
    );
  }

  void _showAddExitDialog(BuildContext context) {
    // Premium Add Exit Dialog placeholder
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Exit Gate'),
        content: const Text('Feature available for verified operators only.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }
}
