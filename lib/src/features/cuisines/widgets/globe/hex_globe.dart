import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart' as vector;

class HexGlobe extends StatefulWidget {
  final List<String> cuisineTypes;
  final Function(String)? onCuisineSelected;
  final double size;
  final Map<String, Color> cuisineColors;

  const HexGlobe({
    Key? key, 
    required this.cuisineTypes,
    this.onCuisineSelected,
    this.size = 300,
    required this.cuisineColors,
  }) : super(key: key);

  @override
  State<HexGlobe> createState() => _HexGlobeState();
}

class _HexGlobeState extends State<HexGlobe> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  double _dragStartX = 0;
  double _dragStartY = 0;
  double _rotationX = 0;
  double _rotationY = 0;
  double _currentRotationX = 0;
  double _currentRotationY = 0;
  bool _isDragging = false;
  double _scale = 1.0;
  String? _hoveredRegion;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 30000),
      vsync: this,
    )..repeat();

    _animationController.addListener(() {
      if (!_isDragging) {
        setState(() {
          _rotationY = _currentRotationY + _animationController.value * 2 * math.pi;
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onScaleStart: _handleScaleStart,
      onScaleUpdate: _handleScaleUpdate,
      onScaleEnd: _handleScaleEnd,
      child: MouseRegion(
        onHover: (event) {
          // Calculate which region is being hovered based on event position
          // This is a simplified version - you would need proper 3D calculations
          final RenderBox box = context.findRenderObject() as RenderBox;
          final localPosition = box.globalToLocal(event.position);
          
          // Simple hover detection for demonstration
          // In a real implementation, this would require ray casting to the sphere
          final String? hoveredRegion = _getHoveredRegion(localPosition);
          if (hoveredRegion != _hoveredRegion) {
            setState(() {
              _hoveredRegion = hoveredRegion;
            });
          }
        },
        onExit: (_) {
          setState(() {
            _hoveredRegion = null;
          });
        },
        child: Center(
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001) // perspective
              ..rotateX(_rotationX)
              ..rotateY(_rotationY)
              ..scale(_scale),
            child: SizedBox(
              width: widget.size,
              height: widget.size,
              child: CustomPaint(
                painter: HexGlobePainter(
                  cuisineTypes: widget.cuisineTypes,
                  cuisineColors: widget.cuisineColors,
                  hoveredRegion: _hoveredRegion,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleScaleStart(ScaleStartDetails details) {
    _animationController.stop();
    _isDragging = true;
    _dragStartX = details.localFocalPoint.dy;
    _dragStartY = details.localFocalPoint.dx;
  }

  void _handleScaleUpdate(ScaleUpdateDetails details) {
    setState(() {
      // Update rotation based on drag
      final double dragDeltaX = details.localFocalPoint.dy - _dragStartX;
      final double dragDeltaY = details.localFocalPoint.dx - _dragStartY;
      
      // Adjust rotation sensitivity
      _rotationX = _currentRotationX + dragDeltaX * 0.01;
      _rotationY = _currentRotationY + dragDeltaY * 0.01;
      
      // Update scale if pinch zoom
      if (details.scale != 1.0) {
        _scale = (_scale * details.scale).clamp(0.5, 2.0);
      }
    });
  }

  void _handleScaleEnd(ScaleEndDetails details) {
    _isDragging = false;
    _currentRotationX = _rotationX;
    _currentRotationY = _rotationY;
    _animationController.forward(from: _animationController.value);
  }

  String? _getHoveredRegion(Offset localPosition) {
    // This is a simplified version of region detection
    // A more accurate implementation would do ray casting on the globe
    
    final center = Offset(widget.size / 2, widget.size / 2);
    final distance = (localPosition - center).distance;
    
    // Only detect hover if within the globe radius
    if (distance > widget.size / 2) {
      return null;
    }
    
    // Convert screen position to normalized spherical coordinates
    final dx = (localPosition.dx - center.dx) / (widget.size / 2);
    final dy = (localPosition.dy - center.dy) / (widget.size / 2);
    
    // Calculate theta (longitude) and phi (latitude) from sphere position
    final phi = math.asin(dy);
    final theta = math.atan2(dx, math.sqrt(1 - dx * dx - dy * dy));
    
    // Apply current rotation to get the actual position on the globe
    final matrix = Matrix4.identity()
      ..rotateX(_rotationX)
      ..rotateY(_rotationY);
    
    // Convert to Cartesian coordinates
    final radius = widget.size / 2;
    final x = radius * math.cos(phi) * math.sin(theta);
    final y = radius * math.sin(phi);
    final z = radius * math.cos(phi) * math.cos(theta);
    
    // Apply rotation transform
    final vector3 = vector.Vector3(x, y, z);
    final transformed = matrix.transform3(vector3);
    
    // Convert back to spherical coordinates
    final latitude = math.asin(transformed.y / radius) * 180 / math.pi;
    final longitude = math.atan2(transformed.x, transformed.z) * 180 / math.pi;
    
    // Map coordinates to cuisine regions
    // This is a simplified mapping - you would need a more detailed mapping
    return _getRegionFromCoordinates(latitude, longitude);
  }

  String? _getRegionFromCoordinates(double latitude, double longitude) {
    // Simplified region mapping - would be more detailed in a real implementation
    if (latitude > 30) {
      if (longitude < -30) return 'European';
      if (longitude < 60) return 'Asian';
      return 'North American';
    } else if (latitude > 0) {
      if (longitude < 0) return 'African';
      return 'Middle Eastern';
    } else {
      if (longitude < 0) return 'South American';
      return 'Oceanian';
    }
  }
}

class HexGlobePainter extends CustomPainter {
  final List<String> cuisineTypes;
  final Map<String, Color> cuisineColors;
  final String? hoveredRegion;
  final int hexDensity = 20; // Controls density of hexagons
  
  HexGlobePainter({
    required this.cuisineTypes,
    required this.cuisineColors,
    this.hoveredRegion,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double radius = size.width / 2;
    final Offset center = Offset(size.width / 2, size.height / 2);
    
    // Draw base globe
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.8)
      ..style = PaintingStyle.fill;
      
    canvas.drawCircle(center, radius, paint);
    
    // Draw hexagonal grid
    _drawHexagonalGrid(canvas, size);
    
    // Draw highlight if a region is hovered
    if (hoveredRegion != null) {
      _drawHoveredRegion(canvas, size, hoveredRegion!);
    }
  }
  
  void _drawHexagonalGrid(Canvas canvas, Size size) {
    final double radius = size.width / 2;
    final Offset center = Offset(size.width / 2, size.height / 2);
    
    // Calculate hexagon size based on density
    final hexSize = radius * 2 / hexDensity;
    
    // Generate a field of hexagons covering the sphere
    for (int i = 0; i < hexDensity; i++) {
      for (int j = 0; j < hexDensity; j++) {
        // Calculate hexagon position (evenly distributed)
        final x = i * hexSize * 0.75 - radius + hexSize / 2;
        final y = j * hexSize * 0.866 - radius + hexSize / 2;
        
        // Offset every other row
        final offsetX = j % 2 == 0 ? 0 : hexSize * 0.375;
        
        final hexCenter = Offset(center.dx + x + offsetX, center.dy + y);
        
        // Only draw hexagons that fall within the circle
        if ((hexCenter - center).distance <= radius) {
          _drawHexagon(canvas, hexCenter, hexSize * 0.45, _getColorForPosition(hexCenter, size));
        }
      }
    }
  }
  
  void _drawHexagon(Canvas canvas, Offset center, double size, Color color) {
    final path = Path();
    final paint = Paint()
      ..color = color
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
    
    // Draw a thin border
    final borderPaint = Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;
      
    canvas.drawPath(path, borderPaint);
  }
  
  void _drawHoveredRegion(Canvas canvas, Size size, String region) {
    // Simplified highlighting of a region
    // In a real implementation, you'd want to highlight all hexagons in that region
    
    final double radius = size.width / 2;
    final Offset center = Offset(size.width / 2, size.height / 2);
    
    // Draw a subtle glow around the globe for the hovered region
    final paint = Paint()
      ..color = _getColorForRegion(region).withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8.0;
      
    canvas.drawCircle(center, radius + 5, paint);
    
    // Draw region name
    final textSpan = TextSpan(
      text: region,
      style: TextStyle(
        color: Colors.white,
        fontSize: 24,
        fontWeight: FontWeight.bold,
        shadows: [
          Shadow(
            blurRadius: 8.0,
            color: Colors.black.withOpacity(0.7),
            offset: const Offset(2, 2),
          ),
        ],
      ),
    );
    
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    
    textPainter.layout();
    textPainter.paint(
      canvas, 
      Offset(center.dx - textPainter.width / 2, size.height - textPainter.height - 20),
    );
  }
  
  Color _getColorForPosition(Offset position, Size size) {
    // Map position to region
    final center = Offset(size.width / 2, size.height / 2);
    final dx = (position.dx - center.dx) / (size.width / 2);
    final dy = (position.dy - center.dy) / (size.height / 2);
    
    // Convert to spherical coordinates (simplified)
    final phi = math.asin(dy);
    final theta = math.atan2(dx, math.sqrt(1 - dx * dx - dy * dy));
    
    // Convert to latitude/longitude
    final latitude = phi * 180 / math.pi;
    final longitude = theta * 180 / math.pi;
    
    // Get region from coordinates
    final region = _getRegionFromCoordinates(latitude, longitude);
    
    // Get color for region
    return _getColorForRegion(region);
  }
  
  String _getRegionFromCoordinates(double latitude, double longitude) {
    // Simplified region mapping
    if (latitude > 30) {
      if (longitude < -30) return 'European';
      if (longitude < 60) return 'Asian';
      return 'North American';
    } else if (latitude > 0) {
      if (longitude < 0) return 'African';
      return 'Middle Eastern';
    } else {
      if (longitude < 0) return 'South American';
      return 'Oceanian';
    }
  }
  
  Color _getColorForRegion(String region) {
    // Try to get the color from the cuisineColors map first
    if (cuisineColors.containsKey(region)) {
      return cuisineColors[region]!;
    }
    
    // Default colors for different regions
    switch (region) {
      case 'European':
        return Colors.blue.shade700;
      case 'Asian':
        return Colors.red.shade700;
      case 'North American':
        return Colors.green.shade700;
      case 'South American': 
        return Colors.yellow.shade700;
      case 'African':
        return Colors.orange.shade700;
      case 'Oceanian':
        return Colors.purple.shade700;
      case 'Middle Eastern':
        return Colors.amber.shade700;
      default:
        // Generate a random color for other cuisines
        return Color((math.Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
