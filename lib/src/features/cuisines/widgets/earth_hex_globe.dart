import 'dart:math' as math;
import 'package:flutter/material.dart';

class EarthHexGlobe extends StatefulWidget {
  final Map<String, Color> regionColors;
  final Function(String)? onRegionSelected;
  
  const EarthHexGlobe({
    Key? key,
    required this.regionColors,
    this.onRegionSelected,
  }) : super(key: key);

  @override
  State<EarthHexGlobe> createState() => _EarthHexGlobeState();
}

class _EarthHexGlobeState extends State<EarthHexGlobe>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _rotationY = 0.0;
  double _rotationX = 0.0;
  bool _isDragging = false;
  String? _hoveredRegion;
  double _scale = 1.0;
  
  // Continent shapes in approximate relative positions
  final Map<String, List<List<int>>> _continentShapes = {
    'North American': [
      [25, 12], [24, 13], [23, 13], [22, 14], [21, 15], [20, 16], [19, 17],
      [19, 18], [19, 19], [20, 20], [21, 21], [22, 22], [23, 22], [24, 21], [25, 20],
      [26, 19], [27, 18], [28, 17], [29, 16], [30, 15], [29, 14], [28, 13], [27, 12], [26, 12]
    ],
    'South American': [
      [25, 25], [24, 26], [24, 27], [24, 28], [23, 29], [23, 30], [24, 31],
      [25, 32], [26, 32], [27, 31], [28, 30], [29, 29], [30, 28], [30, 27],
      [29, 26], [28, 25], [27, 24], [26, 24]
    ],
    'European': [
      [36, 14], [37, 15], [38, 15], [39, 14], [40, 13], [41, 12], [42, 12],
      [43, 13], [44, 14], [45, 14], [45, 15], [44, 16], [43, 17], [42, 18],
      [41, 19], [40, 19], [39, 18], [38, 17], [37, 16], [36, 15]
    ],
    'African': [
      [38, 20], [39, 21], [40, 22], [41, 23], [42, 24], [43, 25], [44, 26],
      [44, 27], [43, 28], [42, 29], [41, 30], [40, 31], [39, 31], [38, 30],
      [37, 29], [36, 28], [36, 27], [36, 26], [37, 25], [38, 24], [38, 23],
      [37, 22], [37, 21]
    ],
    'Asian': [
      [46, 16], [47, 15], [48, 14], [49, 13], [50, 13], [51, 14], [52, 15],
      [53, 16], [54, 17], [55, 18], [56, 19], [57, 20], [58, 21], [58, 22],
      [57, 23], [56, 24], [55, 25], [54, 25], [53, 24], [52, 23], [51, 22],
      [50, 21], [49, 20], [48, 19], [47, 18], [46, 17]
    ],
    'Oceanian': [
      [55, 28], [56, 29], [57, 30], [58, 31], [59, 32], [60, 33], [60, 34],
      [59, 35], [58, 35], [57, 34], [56, 33], [55, 32], [54, 31], [54, 30],
      [55, 29]
    ],
    'Middle Eastern': [
      [45, 19], [46, 20], [47, 21], [48, 21], [48, 22], [47, 23], [46, 23],
      [45, 22], [44, 21], [44, 20]
    ],
    // Ocean is represented by absence of continents
  };

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
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
          child: GestureDetector(
            onScaleStart: _handleScaleStart,
            onScaleUpdate: _handleScaleUpdate,
            onScaleEnd: _handleScaleEnd,
            onTapUp: _handleTapUp,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 15,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: ClipOval(
                child: Stack(
                  children: [
                    // Deep ocean background with a subtle blue gradient
                    Container(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          colors: [
                            const Color(0xFF1A237E).withOpacity(0.3),
                            Colors.black,
                          ],
                          center: Alignment.center,
                          radius: 1.0,
                        ),
                      ),
                    ),
                    
                    // Hexagonal Earth
                    CustomPaint(
                      size: Size(size, size),
                      painter: EarthHexGridPainter(
                        rotationY: _rotationY,
                        rotationX: _rotationX,
                        regionColors: widget.regionColors,
                        hoveredRegion: _hoveredRegion,
                        continentShapes: _continentShapes,
                        scale: _scale,
                      ),
                    ),
                    
                    // Show region name when hovered/selected
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
                      
                    // Instructions overlay (fades out after 5 seconds)
                    Positioned(
                      top: 10,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Drag to rotate • Pinch to zoom',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
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
  
  void _handleScaleStart(ScaleStartDetails details) {
    _isDragging = true;
    _controller.stop();
  }
  
  void _handleScaleUpdate(ScaleUpdateDetails details) {
    setState(() {
      // Update rotation based on drag
      _rotationY = (_rotationY + details.focalPointDelta.dx / 100) % (2 * math.pi);
      _rotationX = (_rotationX + details.focalPointDelta.dy / 100).clamp(-math.pi / 4, math.pi / 4);
      
      // Update scale if pinch zoom
      if (details.scale != 1.0) {
        _scale = (_scale * details.scale).clamp(0.8, 1.5);
      }
    });
  }
  
  void _handleScaleEnd(ScaleEndDetails details) {
    _isDragging = false;
    _controller.forward(from: _rotationY / (2 * math.pi));
  }
  
  void _handleTapUp(TapUpDetails details) {
    final RenderBox box = context.findRenderObject() as RenderBox;
    final Offset localPosition = box.globalToLocal(details.globalPosition);
    final Size size = box.size;
    
    // Find which region was tapped
    final String? region = _getRegionAtPosition(localPosition, size);
    if (region != null && widget.onRegionSelected != null) {
      widget.onRegionSelected!(region);
      
      // Show a brief highlighting effect
      setState(() {
        _hoveredRegion = region;
      });
      
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) {
          setState(() {
            _hoveredRegion = null;
          });
        }
      });
    }
  }
  
  String? _getRegionAtPosition(Offset position, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    
    // Check if click is within globe
    if ((position - center).distance > radius) {
      return null;
    }
    
    // Convert to normalized coordinates for hit testing
    final normalizedX = (position.dx - center.dx) / radius;
    final normalizedY = (position.dy - center.dy) / radius;
    
    // Apply rotation to find actual position on globe
    // This is a simplified calculation - in a production app you would use 
    // proper 3D transformations with matrices
    final cosY = math.cos(_rotationY);
    final sinY = math.sin(_rotationY);
    final cosX = math.cos(_rotationX);
    final sinX = math.sin(_rotationX);
    
    final transformedX = normalizedX * cosY - normalizedY * sinY;
    final transformedY = normalizedX * sinY * sinX + normalizedY * cosY * cosX;
    
    // Convert to cell coordinates in our grid
    // The grid is 80x40 cells
    final cellX = ((transformedX + 1) / 2 * 80).round();
    final cellY = ((transformedY + 1) / 2 * 40).round();
    
    // Check which continent contains this point
    for (final entry in _continentShapes.entries) {
      final region = entry.key;
      final shape = entry.value;
      
      for (final point in shape) {
        // Check if the cell is within range of this point (allowing some tolerance)
        if ((point[0] - cellX).abs() <= 2 && (point[1] - cellY).abs() <= 2) {
          return region;
        }
      }
    }
    
    // If not in any continent, return "Ocean" or null
    return null;
  }
}

class EarthHexGridPainter extends CustomPainter {
  final double rotationY;
  final double rotationX;
  final Map<String, Color> regionColors;
  final String? hoveredRegion;
  final Map<String, List<List<int>>> continentShapes;
  final double scale;
  
  EarthHexGridPainter({
    required this.rotationY,
    required this.rotationX,
    required this.regionColors,
    this.hoveredRegion,
    required this.continentShapes,
    this.scale = 1.0,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    
    // Draw the base ocean globe
    final oceanPaint = Paint()
      ..color = const Color(0xFF0D47A1).withOpacity(0.3)
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(center, radius, oceanPaint);
    
    // Calculate hexagon size based on globe size - we want a grid of about 40 hexagons across
    final hexSize = radius / 20;
    
    // Draw ocean hexagons first for the base layer
    _drawOceanHexagons(canvas, size, hexSize);
    
    // Draw continent hexagons on top
    _drawContinentHexagons(canvas, size, hexSize);
  }
  
  void _drawOceanHexagons(Canvas canvas, Size size, double hexSize) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    
    // Draw a base layer of blue hexagons for the ocean
    // Using a slightly different grid pattern than continents for a more interesting look
    for (int row = -30; row <= 30; row += 2) {
      for (int col = -30; col <= 30; col += 2) {
        // Position hexagons in a grid 
        final gridX = col * hexSize * 1.5;
        final gridY = row * hexSize * 1.732 + (col.isEven ? 0 : hexSize * 0.866);
        
        // Apply 3D rotation (simplified)
        final x = center.dx + (gridX * math.cos(rotationY) - gridY * math.sin(rotationY)) * scale;
        final y = center.dy + (gridY * math.cos(rotationX)) * scale;
        
        final hexCenter = Offset(x, y);
        
        // Only draw if within the circle and check z-ordering (simplified)
        final zOrder = gridX * math.sin(rotationY) + gridY * math.sin(rotationX);
        if ((hexCenter - center).distance <= radius - hexSize && zOrder < radius/2) {
          _drawHexagon(
            canvas, 
            hexCenter, 
            hexSize * 0.9,
            const Color(0xFF0D47A1).withOpacity(0.3),
            strokeColor: Colors.black12,
          );
        }
      }
    }
  }
  
  void _drawContinentHexagons(Canvas canvas, Size size, double hexSize) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    
    // First, we'll create a lookup map for continent cells
    final Map<String, Set<String>> continentCells = {};
    
    for (final entry in continentShapes.entries) {
      final region = entry.key;
      final shape = entry.value;
      
      continentCells[region] = <String>{};
      
      // Add each cell plus surrounding cells for a better filled shape
      for (final point in shape) {
        final x = point[0];
        final y = point[1];
        
        // Add center and neighbors to create a more solid shape
        for (int nx = -1; nx <= 1; nx++) {
          for (int ny = -1; ny <= 1; ny++) {
            continentCells[region]!.add('${x + nx}_${y + ny}');
          }
        }
      }
    }
    
    // Now draw the continent hexagons with our lookup map
    for (int row = 0; row < 40; row++) {
      for (int col = 0; col < 80; col++) {
        String? cellRegion;
        
        // Find which region this cell belongs to
        for (final entry in continentCells.entries) {
          if (entry.value.contains('${col}_$row')) {
            cellRegion = entry.key;
            break;
          }
        }
        
        if (cellRegion != null) {
          // Convert grid position to canvas coordinates
          final gridX = (col - 40) * hexSize * 1.5;
          final gridY = (row - 20) * hexSize * 1.732 + (col.isEven ? 0 : hexSize * 0.866);
          
          // Apply 3D rotation
          final x = center.dx + (gridX * math.cos(rotationY) - gridY * math.sin(rotationY)) * scale;
          final y = center.dy + (gridY * math.cos(rotationX)) * scale;
          
          final hexCenter = Offset(x, y);
          
          // Z-ordering for 3D effect (simplified)
          final zOrder = gridX * math.sin(rotationY) + gridY * math.sin(rotationX);
          
          // Only draw if within the circle and on the visible side of the globe
          if ((hexCenter - center).distance <= radius - hexSize && zOrder < radius/2) {
            final color = regionColors[cellRegion] ?? Colors.grey;
            final isHighlighted = cellRegion == hoveredRegion;
            
            _drawHexagon(
              canvas, 
              hexCenter, 
              hexSize * 0.9, 
              isHighlighted ? color : color.withOpacity(0.7),
              strokeColor: isHighlighted ? color.withOpacity(0.9) : Colors.black26,
              strokeWidth: isHighlighted ? 1.5 : 0.5,
              elevated: isHighlighted,
            );
          }
        }
      }
    }
  }
  
  void _drawHexagon(
    Canvas canvas, 
    Offset center, 
    double size, 
    Color color, {
    Color strokeColor = Colors.black12, 
    double strokeWidth = 0.5,
    bool elevated = false,
  }) {
    final path = Path();
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    
    // Create slightly elevated hexagons for highlighted regions
    final elevationOffset = elevated ? -2.0 : 0.0;
    
    // Create hexagon points
    for (int i = 0; i < 6; i++) {
      final angle = i * math.pi / 3;
      final x = center.dx + size * math.cos(angle);
      final y = center.dy + size * math.sin(angle) + elevationOffset;
      
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
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    
    canvas.drawPath(path, borderPaint);
    
    // Add a subtle highlight for elevated hexagons
    if (elevated) {
      final highlightPaint = Paint()
        ..color = Colors.white.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;
      
      canvas.drawPath(path, highlightPaint);
    }
  }
  
  @override
  bool shouldRepaint(covariant EarthHexGridPainter oldDelegate) =>
      rotationY != oldDelegate.rotationY ||
      rotationX != oldDelegate.rotationX ||
      hoveredRegion != oldDelegate.hoveredRegion ||
      scale != oldDelegate.scale;
}
