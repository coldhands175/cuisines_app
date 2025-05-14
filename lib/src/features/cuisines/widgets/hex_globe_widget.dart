import 'dart:math' as math;
import 'package:flutter/material.dart';

class HexGlobeWidget extends StatefulWidget {
  final Map<String, Color> regionColors;
  final Function(String)? onRegionSelected;
  
  const HexGlobeWidget({
    Key? key,
    required this.regionColors,
    this.onRegionSelected,
  }) : super(key: key);

  @override
  State<HexGlobeWidget> createState() => _HexGlobeWidgetState();
}

class _HexGlobeWidgetState extends State<HexGlobeWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _rotationY = 0.0;
  double _rotationX = 0.0;
  bool _isDragging = false;
  String? _hoveredRegion;
  
  final Map<String, List<Offset>> _regionsMap = {
    'European': [Offset(0.3, 0.3), Offset(0.4, 0.25), Offset(0.5, 0.3)],
    'Asian': [Offset(0.6, 0.3), Offset(0.7, 0.35), Offset(0.8, 0.3)],
    'North American': [Offset(0.2, 0.3), Offset(0.25, 0.25), Offset(0.15, 0.35)],
    'South American': [Offset(0.3, 0.6), Offset(0.25, 0.7), Offset(0.35, 0.65)],
    'African': [Offset(0.5, 0.5), Offset(0.45, 0.6), Offset(0.55, 0.55)],
    'Oceanian': [Offset(0.8, 0.7), Offset(0.75, 0.65), Offset(0.85, 0.7)],
    'Middle Eastern': [Offset(0.55, 0.4), Offset(0.6, 0.45), Offset(0.5, 0.45)],
  };

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();
    
    _controller.addListener(() {
      if (!_isDragging) {
        setState(() {
          _rotationY = _controller.value * 2 * math.pi;
        });
      }
    });
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = math.min(constraints.maxWidth, constraints.maxHeight);
        
        return Center(
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: Colors.black87,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 15,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: GestureDetector(
              onPanStart: _handlePanStart,
              onPanUpdate: _handlePanUpdate,
              onPanEnd: _handlePanEnd,
              onTapUp: _handleTapUp,
              child: ClipOval(
                child: Stack(
                  children: [
                    // Background gradient for the globe
                    Container(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          colors: [
                            Colors.blueGrey.shade800,
                            Colors.black,
                          ],
                        ),
                      ),
                    ),
                    
                    // Hexagonal grid
                    CustomPaint(
                      size: Size(size, size),
                      painter: HexGridPainter(
                        rotationY: _rotationY,
                        rotationX: _rotationX,
                        regionColors: widget.regionColors,
                        hoveredRegion: _hoveredRegion,
                        regionsMap: _regionsMap,
                      ),
                    ),
                    
                    // Show region name when hovered
                    if (_hoveredRegion != null)
                      Positioned(
                        bottom: 20,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _hoveredRegion!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
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
    );
  }
  
  void _handlePanStart(DragStartDetails details) {
    _isDragging = true;
    _controller.stop();
  }
  
  void _handlePanUpdate(DragUpdateDetails details) {
    setState(() {
      _rotationY = (_rotationY + details.delta.dx / 100) % (2 * math.pi);
      _rotationX = (_rotationX + details.delta.dy / 100).clamp(-math.pi / 4, math.pi / 4);
    });
  }
  
  void _handlePanEnd(DragEndDetails details) {
    _isDragging = false;
    _controller.forward(from: _rotationY / (2 * math.pi));
  }
  
  void _handleTapUp(TapUpDetails details) {
    final RenderBox box = context.findRenderObject() as RenderBox;
    final Offset localPosition = box.globalToLocal(details.globalPosition);
    final Size size = box.size;
    
    // Normalize the position
    final Offset normalized = Offset(
      localPosition.dx / size.width,
      localPosition.dy / size.height,
    );
    
    // Check which region was tapped
    final String? region = _getRegionAtPosition(normalized);
    if (region != null && widget.onRegionSelected != null) {
      widget.onRegionSelected!(region);
      
      // Show a brief highlighting effect
      setState(() {
        _hoveredRegion = region;
      });
      
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
            _hoveredRegion = null;
          });
        }
      });
    }
  }
  
  String? _getRegionAtPosition(Offset position) {
    // Simple implementation - in a real app you'd use proper hit testing with rotation
    final center = const Offset(0.5, 0.5);
    final distance = (position - center).distance;
    
    // Check if within the circle
    if (distance > 0.5) return null;
    
    // Apply rotation transformation (simplified)
    final adjustedX = position.dx;
    final adjustedY = position.dy;
    
    // Find the nearest region
    String? closestRegion;
    double minDistance = double.infinity;
    
    for (final entry in _regionsMap.entries) {
      for (final point in entry.value) {
        final pointDistance = (Offset(adjustedX, adjustedY) - point).distance;
        if (pointDistance < minDistance) {
          minDistance = pointDistance;
          closestRegion = entry.key;
        }
      }
    }
    
    // Only return if we're close enough
    return minDistance < 0.15 ? closestRegion : null;
  }
}

class HexGridPainter extends CustomPainter {
  final double rotationY;
  final double rotationX;
  final Map<String, Color> regionColors;
  final String? hoveredRegion;
  final Map<String, List<Offset>> regionsMap;
  
  HexGridPainter({
    required this.rotationY,
    required this.rotationX,
    required this.regionColors,
    this.hoveredRegion,
    required this.regionsMap,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    
    // Draw the base globe
    final paint = Paint()
      ..color = Colors.blueGrey.shade900
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(center, radius, paint);
    
    // Calculate hexagon size based on globe size
    final hexSize = radius / 10;
    
    // Create a grid of hexagons
    _drawHexagonGrid(canvas, size, hexSize);
    
    // Draw highlighted regions
    _drawRegions(canvas, size, hexSize);
  }
  
  void _drawHexagonGrid(Canvas canvas, Size size, double hexSize) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    
    // Grid density - increase for more hexagons
    final density = 20;
    
    for (int row = -density; row <= density; row++) {
      for (int col = -density; col <= density; col++) {
        // Position hexagons in a grid with offset for even rows
        final offsetX = col * hexSize * 1.5;
        final offsetY = row * hexSize * 1.732 + (col % 2 == 0 ? 0 : hexSize * 0.866);
        
        final hexCenter = Offset(
          center.dx + offsetX * math.cos(rotationY) - offsetY * math.sin(rotationY),
          center.dy + offsetY * math.cos(rotationX),
        );
        
        // Only draw hexagons within the circle
        if ((hexCenter - center).distance <= radius - hexSize) {
          // Calculate hexagon color based on position
          final regionInfo = _getRegionInfoFromPosition(
            Offset(
              (hexCenter.dx - center.dx) / radius + 0.5,
              (hexCenter.dy - center.dy) / radius + 0.5,
            )
          );
          
          // Draw the hexagon
          _drawHexagon(
            canvas, 
            hexCenter, 
            hexSize * 0.8, 
            regionInfo.color,
            isHighlighted: regionInfo.name == hoveredRegion,
          );
        }
      }
    }
  }
  
  void _drawHexagon(Canvas canvas, Offset center, double size, Color color, {bool isHighlighted = false}) {
    final path = Path();
    final paint = Paint()
      ..color = isHighlighted ? color.withOpacity(0.8) : color.withOpacity(0.5)
      ..style = PaintingStyle.fill;
    
    // Create hexagon points
    for (int i = 0; i < 6; i++) {
      final angle = i * math.pi / 3;
      final x = center.dx + size * math.cos(angle);
      final y = center.dy + size * math.sin(angle);
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    
    path.close();
    canvas.drawPath(path, paint);
    
    // Draw hexagon border
    final borderPaint = Paint()
      ..color = Colors.black12
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;
    
    canvas.drawPath(path, borderPaint);
  }
  
  void _drawRegions(Canvas canvas, Size size, double hexSize) {
    // Draw specific regions with their colors
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    
    for (final entry in regionsMap.entries) {
      final regionName = entry.key;
      final regionPoints = entry.value;
      final regionColor = regionColors[regionName] ?? Colors.grey;
      
      for (final point in regionPoints) {
        // Transform the point based on rotation
        final adjustedX = center.dx + (point.dx - 0.5) * radius * 2 * math.cos(rotationY);
        final adjustedY = center.dy + (point.dy - 0.5) * radius * 2 * math.cos(rotationX);
        
        // Draw a cluster of hexagons around each region point
        for (int i = -2; i <= 2; i++) {
          for (int j = -2; j <= 2; j++) {
            final clusterCenter = Offset(
              adjustedX + i * hexSize * 1.2,
              adjustedY + j * hexSize * 1.2 + (i % 2 == 0 ? 0 : hexSize * 0.6),
            );
            
            // Only draw if within globe radius
            if ((clusterCenter - center).distance <= radius - hexSize) {
              _drawHexagon(
                canvas, 
                clusterCenter, 
                hexSize, 
                regionColor,
                isHighlighted: regionName == hoveredRegion,
              );
            }
          }
        }
      }
    }
  }
  
  _RegionInfo _getRegionInfoFromPosition(Offset normalizedPosition) {
    // Find the nearest region center
    String closestRegion = 'European'; // Default
    double minDistance = double.infinity;
    
    for (final entry in regionsMap.entries) {
      for (final point in entry.value) {
        final distance = (normalizedPosition - point).distance;
        if (distance < minDistance) {
          minDistance = distance;
          closestRegion = entry.key;
        }
      }
    }
    
    // Get the color for this region
    final color = regionColors[closestRegion] ?? Colors.grey;
    
    return _RegionInfo(closestRegion, color);
  }
  
  @override
  bool shouldRepaint(covariant HexGridPainter oldDelegate) =>
      rotationY != oldDelegate.rotationY ||
      rotationX != oldDelegate.rotationX ||
      hoveredRegion != oldDelegate.hoveredRegion;
}

class _RegionInfo {
  final String name;
  final Color color;
  
  _RegionInfo(this.name, this.color);
}
