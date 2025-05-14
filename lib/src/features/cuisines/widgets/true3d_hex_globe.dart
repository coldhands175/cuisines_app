import 'dart:math' as math;
import 'package:flutter/material.dart';

class True3DHexGlobe extends StatefulWidget {
  final Map<String, Color> regionColors;
  final Function(String)? onRegionSelected;
  final String? highlightedRegion; // Added to highlight region from outside
  final bool animateHighlight; // Controls whether to animate the highlighted region
  
  const True3DHexGlobe({
    Key? key,
    required this.regionColors,
    this.onRegionSelected,
    this.highlightedRegion,
    this.animateHighlight = false,
  }) : super(key: key);

  @override
  State<True3DHexGlobe> createState() => _True3DHexGlobeState();
}

class _True3DHexGlobeState extends State<True3DHexGlobe>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;
  
  double _rotationY = 0.0;
  double _rotationX = 0.0;
  bool _isDragging = false;
  String? _hoveredRegion;
  String? _activeRegion; // Currently highlighted region
  double _scale = 1.0;
  bool _isAnimating = false;
  
  // Earth coordinate definition - this defines the mapping of our sphere
  // Detailed earth coordinates [longitude, latitude, region]
  // More coordinates for a more accurate representation of continents
  final List<List<dynamic>> _earthCoordinates = [
    // North America
    // United States
    [-98.0, 39.5, 'North American'],  // Central US
    [-118.0, 34.0, 'North American'], // Los Angeles
    [-74.0, 40.7, 'North American'],   // New York
    [-87.0, 41.8, 'North American'],   // Chicago
    [-95.0, 29.7, 'North American'],   // Houston
    [-122.4, 37.7, 'North American'],  // San Francisco
    // Canada
    [-106.0, 50.0, 'North American'],  // Central Canada
    [-79.0, 43.6, 'North American'],   // Toronto
    [-123.1, 49.2, 'North American'],  // Vancouver
    // Mexico
    [-99.0, 19.0, 'North American'],   // Mexico City
    [-86.0, 20.0, 'North American'],   // Cancun
    
    // Central America
    [-85.0, 12.0, 'North American'],   // Nicaragua
    [-90.0, 14.0, 'North American'],   // Guatemala
    [-84.0, 9.0, 'North American'],    // Costa Rica
    
    // South America
    [-58.0, -34.5, 'South American'],  // Buenos Aires
    [-46.5, -23.5, 'South American'],  // São Paulo
    [-74.0, 4.5, 'South American'],    // Colombia
    [-77.0, -12.0, 'South American'],  // Lima, Peru
    [-70.0, -33.0, 'South American'],  // Santiago, Chile
    [-67.0, -55.0, 'South American'],  // Southern Argentina
    [-56.0, -15.0, 'South American'],  // Brazil center
    [-66.0, -17.0, 'South American'],  // Bolivia
    
    // Europe
    [2.3, 48.8, 'European'],           // Paris
    [13.4, 52.5, 'European'],          // Berlin
    [12.5, 41.9, 'European'],          // Rome
    [-0.1, 51.5, 'European'],          // London
    [4.9, 52.3, 'European'],           // Amsterdam
    [9.2, 45.4, 'European'],           // Milan
    [16.3, 48.2, 'European'],          // Vienna
    [21.0, 52.2, 'European'],          // Warsaw
    [18.0, 59.3, 'European'],          // Stockholm
    [37.6, 55.7, 'European'],          // Moscow
    [23.7, 38.0, 'European'],          // Athens
    [-3.7, 40.4, 'European'],          // Madrid
    [14.4, 50.0, 'European'],          // Prague
    [19.0, 47.5, 'European'],          // Budapest
    
    // Africa
    [3.0, 36.7, 'African'],            // Algeria
    [32.0, 0.0, 'African'],            // Uganda
    [38.0, 8.0, 'African'],            // Ethiopia
    [18.0, 15.0, 'African'],           // Chad
    [8.0, 9.0, 'African'],             // Nigeria
    [22.0, -33.0, 'African'],          // South Africa
    [36.0, -1.0, 'African'],           // Kenya
    [31.0, 30.0, 'African'],           // Egypt
    [-17.0, 14.0, 'African'],          // Senegal
    [-1.0, 8.0, 'African'],            // Ghana
    [28.0, -20.0, 'African'],          // Zimbabwe
    [13.0, -8.5, 'African'],           // Angola
    
    // Asia
    [116.4, 39.9, 'Asian'],            // Beijing
    [121.5, 31.2, 'Asian'],            // Shanghai
    [139.7, 35.7, 'Asian'],            // Tokyo
    [127.0, 37.5, 'Asian'],            // Seoul
    [77.2, 28.6, 'Asian'],             // Delhi
    [72.8, 19.0, 'Asian'],             // Mumbai
    [100.5, 13.7, 'Asian'],            // Bangkok
    [106.7, 10.8, 'Asian'],            // Ho Chi Minh City
    [103.8, 1.3, 'Asian'],             // Singapore
    [110.0, 30.0, 'Asian'],            // Central China
    [95.0, 35.0, 'Asian'],             // Tibet region
    [84.0, 28.0, 'Asian'],             // Nepal
    [90.0, 23.7, 'Asian'],             // Bangladesh
    [125.0, 40.0, 'Asian'],            // North Korea
    [105.0, 15.0, 'Asian'],            // Vietnam center
    
    // Oceania
    [151.2, -33.9, 'Oceanian'],        // Sydney
    [144.9, -37.8, 'Oceanian'],        // Melbourne
    [174.8, -36.8, 'Oceanian'],        // Auckland, NZ
    [115.8, -31.9, 'Oceanian'],        // Perth
    [153.0, -27.5, 'Oceanian'],        // Brisbane
    [147.0, -9.5, 'Oceanian'],         // Papua New Guinea
    [168.0, -17.0, 'Oceanian'],        // Vanuatu
    
    // Middle East
    [35.2, 31.7, 'Middle Eastern'],    // Jerusalem
    [44.4, 33.3, 'Middle Eastern'],    // Baghdad
    [51.4, 25.3, 'Middle Eastern'],    // Qatar
    [45.0, 25.0, 'Middle Eastern'],    // Saudi Arabia
    [55.3, 25.2, 'Middle Eastern'],    // Dubai
    [51.4, 35.7, 'Middle Eastern'],    // Tehran
    [39.0, 34.8, 'Middle Eastern'],    // Syria
    [36.0, 31.9, 'Middle Eastern'],    // Jordan
    [31.0, 30.0, 'Middle Eastern'],    // Cairo (overlaps with Africa)
  ];

  @override
  void initState() {
    super.initState();
    // Basic rotation animation
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat();
    
    _rotationController.addListener(() {
      if (!_isDragging && !_isAnimating) {
        setState(() {
          _rotationY = _rotationController.value * 2 * math.pi;
        });
      }
    });
    
    // Pulse animation for highlight
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _pulseController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _pulseController.reverse();
      } else if (status == AnimationStatus.dismissed && widget.animateHighlight) {
        _pulseController.forward();
      }
    });
    
    // Bounce animation for hexagons
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _bounceAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.elasticOut,
    ));
    
    _bounceController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _isAnimating = false;
        });
      }
    });
  }
  
  @override
  void didUpdateWidget(True3DHexGlobe oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // React to changes in highlighted region
    if (widget.highlightedRegion != oldWidget.highlightedRegion && 
        widget.highlightedRegion != null) {
      _activeRegion = widget.highlightedRegion;
      _animateToRegion(widget.highlightedRegion!);
    }
    
    // Start/stop pulse animation based on animateHighlight property
    if (widget.animateHighlight && !oldWidget.animateHighlight) {
      _pulseController.forward();
    } else if (!widget.animateHighlight && oldWidget.animateHighlight) {
      _pulseController.stop();
      _pulseController.reset();
    }
  }
  
  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    _bounceController.dispose();
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
                    // Ocean background with a gradient
                    Container(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          colors: [
                            const Color(0xFF1A237E).withOpacity(0.5),
                            Colors.black.withOpacity(0.8),
                          ],
                          center: Alignment.center,
                          radius: 0.8,
                        ),
                      ),
                    ),
                    
                    // 3D Hexagonal Earth with animations
                    AnimatedBuilder(
                      animation: Listenable.merge([
                        _pulseController,
                        _bounceController,
                      ]),
                      builder: (context, child) {
                        return CustomPaint(
                          size: Size(size, size),
                          painter: True3DHexGridPainter(
                            rotationY: _rotationY,
                            rotationX: _rotationX,
                            regionColors: widget.regionColors,
                            hoveredRegion: _hoveredRegion,
                            earthCoordinates: _earthCoordinates,
                            scale: _scale,
                            activeRegion: _activeRegion ?? widget.highlightedRegion,
                            pulseScale: widget.animateHighlight && _activeRegion != null ? 
                                _pulseAnimation.value : 1.0,
                            bounceProgress: _bounceAnimation.value,
                          ),
                        );
                      },
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
                      
                    // Instructions overlay
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
  
  // Animate to center a specific region
  void _animateToRegion(String region) {
    // Find coordinates for this region
    final regionCoords = _findRegionCoordinates(region);
    if (regionCoords == null) return;
    
    // Set that we're animating
    setState(() {
      _isAnimating = true;
    });
    
    // Calculate target rotation to center this region
    final targetRotY = _calculateTargetRotationY(regionCoords.x, regionCoords.z);
    final targetRotX = _calculateTargetRotationX(regionCoords.y);
    
    // Stop current rotation
    _rotationController.stop();
    
    // Create animation to rotate to the target
    final rotationTween = Tween<double>(
      begin: _rotationY,
      end: targetRotY,
    );
    
    final rotationXTween = Tween<double>(
      begin: _rotationX,
      end: targetRotX,
    );
    
    // Use bounce controller for dramatic effect
    _bounceController.reset();
    _bounceController.forward();
    
    // Add listener for animation
    void listener() {
      setState(() {
        _rotationY = rotationTween.evaluate(_bounceAnimation);
        _rotationX = rotationXTween.evaluate(_bounceAnimation);
      });
    }
    
    _bounceController.addListener(listener);
    
    // Clear listener when animation completes
    void statusListener(AnimationStatus status) {
      if (status == AnimationStatus.completed) {
        _bounceController.removeListener(listener);
        _bounceController.removeStatusListener(statusListener);
        
        if (widget.animateHighlight) {
          _pulseController.forward();
        }
        
        // Resume regular rotation after animation
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted && !_isDragging) {
            _rotationController.forward(from: _rotationY / (2 * math.pi));
          }
        });
      }
    }
    
    _bounceController.addStatusListener(statusListener);
  }
  
  // Find the 3D coordinates for a region
  Vector3? _findRegionCoordinates(String region) {
    // Get a coordinate that maps to this region
    for (final coord in _earthCoordinates) {
      if (coord[2] == region) {
        final lon = coord[0].toDouble();
        final lat = coord[1].toDouble();
        return _lonLatTo3D(lon, lat);
      }
    }
    return null;
  }
  
  // Calculate target rotation Y to center a region
  double _calculateTargetRotationY(double x, double z) {
    return math.atan2(x, z);
  }
  
  // Calculate target rotation X to center a region
  double _calculateTargetRotationX(double y) {
    return math.asin(y).clamp(-math.pi / 3, math.pi / 3);
  }

  void _handleScaleStart(ScaleStartDetails details) {
    _isDragging = true;
    _rotationController.stop();
    _pulseController.stop();
  }
  
  void _handleScaleUpdate(ScaleUpdateDetails details) {
    setState(() {
      // Update rotation based on drag
      _rotationY = (_rotationY + details.focalPointDelta.dx / 100) % (2 * math.pi);
      _rotationX = (_rotationX + details.focalPointDelta.dy / 100).clamp(-math.pi / 2 + 0.1, math.pi / 2 - 0.1);
      
      // Update scale if pinch zoom
      if (details.scale != 1.0) {
        _scale = (_scale * details.scale).clamp(0.8, 1.5);
      }
    });
  }
  
  void _handleScaleEnd(ScaleEndDetails details) {
    _isDragging = false;
    
    // Resume standard rotation
    if (!_isAnimating) {
      _rotationController.forward(from: _rotationY / (2 * math.pi));
      
      // Resume pulse animation if needed
      if (widget.animateHighlight && _activeRegion != null) {
        _pulseController.forward();
      }
    }
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
    
    // Convert screen position to ray direction from center
    final Vector3 rayDir = Vector3(
      (position.dx - center.dx) / radius,
      (position.dy - center.dy) / radius,
      math.sqrt(1 - math.pow((position - center).distance / radius, 2)),
    );
    
    // Apply rotation to the ray (inverse of what we do to the sphere)
    final rotatedRay = _rotateRay(rayDir, -_rotationX, -_rotationY);
    
    // Convert ray intersection with sphere to longitude/latitude
    final lon = math.atan2(rotatedRay.x, rotatedRay.z) * 180 / math.pi;
    final lat = math.asin(rotatedRay.y) * 180 / math.pi;
    
    // Find the closest region at this longitude/latitude
    String? closestRegion;
    double minDist = double.infinity;
    
    for (final coord in _earthCoordinates) {
      final coordLon = coord[0].toDouble();
      final coordLat = coord[1].toDouble();
      final region = coord[2] as String;
      
      // Calculate spherical distance
      double dist = _sphericalDistance(lon, lat, coordLon, coordLat);
      
      if (dist < minDist) {
        minDist = dist;
        closestRegion = region;
      }
    }
    
    // Only return a region if we're close enough to a defined point
    return minDist < 30 ? closestRegion : null;
  }
  
  // Calculate spherical distance between two lon/lat points
  double _sphericalDistance(double lon1, double lat1, double lon2, double lat2) {
    const earthRadius = 6371; // Earth's radius in km (not actually used for scaling here)
    final dLat = (lat2 - lat1) * math.pi / 180;
    final dLon = (lon2 - lon1) * math.pi / 180;
    
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
            math.cos(lat1 * math.pi / 180) * math.cos(lat2 * math.pi / 180) *
            math.sin(dLon / 2) * math.sin(dLon / 2);
    
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    final distance = earthRadius * c;
    
    return distance;
  }
  
  // Rotate a vector around the X and Y axes
  Vector3 _rotateRay(Vector3 v, double rotX, double rotY) {
    // First rotate around X axis
    final y1 = v.y * math.cos(rotX) - v.z * math.sin(rotX);
    final z1 = v.y * math.sin(rotX) + v.z * math.cos(rotX);
    
    // Then rotate around Y axis
    final x2 = v.x * math.cos(rotY) + z1 * math.sin(rotY);
    final z2 = -v.x * math.sin(rotY) + z1 * math.cos(rotY);
    
    return Vector3(x2, y1, z2);
  }
}

// Simple 3D vector implementation
class Vector3 {
  final double x;
  final double y;
  final double z;
  
  Vector3(this.x, this.y, this.z);
  
  // Length of the vector
  double get length => math.sqrt(x * x + y * y + z * z);
  
  // Normalize the vector to unit length
  Vector3 normalize() {
    final len = length;
    return Vector3(x / len, y / len, z / len);
  }
  
  // Calculate dot product with another vector
  double dot(Vector3 other) => x * other.x + y * other.y + z * other.z;
}

class True3DHexGridPainter extends CustomPainter {
  final double rotationY;
  final double rotationX;
  final Map<String, Color> regionColors;
  final String? hoveredRegion;
  final List<List<dynamic>> earthCoordinates;
  final double scale;
  final String? activeRegion; // Currently highlighted region
  final double pulseScale; // Scale factor for pulsing animation 
  final double bounceProgress; // Progress of bounce animation (0.0 to 1.0)
  
  True3DHexGridPainter({
    required this.rotationY,
    required this.rotationX,
    required this.regionColors,
    this.hoveredRegion,
    required this.earthCoordinates,
    this.scale = 1.0,
    this.activeRegion,
    this.pulseScale = 1.0,
    this.bounceProgress = 0.0,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 * scale;
    
    // First draw the base ocean sphere with a grid pattern
    _drawOceanSphere(canvas, size, radius);
    
    // Draw the landmasses as hexagons on the sphere surface
    _drawLandmasses(canvas, size, radius);
    
    // Add an ambient occlusion effect around the edges
    _drawSphereEdgeEffect(canvas, size, radius);
  }
  
  void _drawOceanSphere(Canvas canvas, Size size, double radius) {
    final center = Offset(size.width / 2, size.height / 2);
    
    // Draw the base ocean sphere
    final oceanPaint = Paint()
      ..color = const Color(0xFF1A237E).withOpacity(0.4)
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(center, radius, oceanPaint);
    
    // Draw a grid of longitude/latitude lines for the ocean
    final linePaint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.7;
    
    // Draw longitude lines
    for (int lon = -180; lon < 180; lon += 30) {
      final path = Path();
      bool firstPoint = true;
      
      for (int lat = -90; lat <= 90; lat += 5) {
        final point = _sphere3DToScreen(
          size,
          radius,
          center,
          _lonLatTo3D(lon.toDouble(), lat.toDouble()),
          rotationX,
          rotationY,
        );
        
        if (point != null) {
          if (firstPoint) {
            path.moveTo(point.dx, point.dy);
            firstPoint = false;
          } else {
            path.lineTo(point.dx, point.dy);
          }
        }
      }
      
      canvas.drawPath(path, linePaint);
    }
    
    // Draw latitude lines
    for (int lat = -60; lat <= 60; lat += 30) {
      final path = Path();
      bool firstPoint = true;
      bool visible = false;
      
      for (int lon = -180; lon <= 180; lon += 5) {
        final point = _sphere3DToScreen(
          size,
          radius,
          center,
          _lonLatTo3D(lon.toDouble(), lat.toDouble()),
          rotationX,
          rotationY,
        );
        
        if (point != null) {
          visible = true;
          if (firstPoint) {
            path.moveTo(point.dx, point.dy);
            firstPoint = false;
          } else {
            path.lineTo(point.dx, point.dy);
          }
        }
      }
      
      if (visible) {
        canvas.drawPath(path, linePaint);
      }
    }
  }
  
  void _drawLandmasses(Canvas canvas, Size size, double radius) {
    final center = Offset(size.width / 2, size.height / 2);
    
    // Convert all earth coordinates to 3D points and sort by z-order
    final continentPoints = <_RegionHexPoint>[];
    final hexSize = radius * 0.035; // Even smaller hexagons for higher definition
    
    // Process all the coordinate points
    for (final coord in earthCoordinates) {
      final lon = coord[0].toDouble();
      final lat = coord[1].toDouble();
      final region = coord[2] as String;
      
      // Increase the density by creating a very fine grid of hexagons around each coordinate point
      for (int i = -3; i <= 3; i++) {
        for (int j = -3; j <= 3; j++) {
          // Calculate offset coordinates with much finer steps
          final offsetLon = lon + (i * 3.0); // Even finer step: 3 degrees for greater definition
          final offsetLat = lat + (j * 3.0);
          
          // Convert to 3D point
          final offsetPoint3D = _lonLatTo3D(offsetLon, offsetLat);
          
          // Rotate the point
          final rotatedPoint = _rotatePoint(offsetPoint3D, rotationX, rotationY);
          
          // If point is on the visible side of the sphere
          if (rotatedPoint.z > 0) {
            // Project point to screen
            final screenPoint = _project3DPointToScreen(size, radius, center, rotatedPoint);
            
            // Calculate the hexagon size, potentially affected by animations
            double hexagonSize = hexSize * math.sqrt(rotatedPoint.z); // Base size by depth
            
            // Apply pulse animation for the active region
            if (region == activeRegion) {
              hexagonSize *= pulseScale;
            }
            
            // Apply bounce animation for active or hovered region
            if (bounceProgress > 0 && region == activeRegion) {
              // Apply elastic bounce effect
              final bounceOffset = math.sin(bounceProgress * math.pi * 3) * (1.0 - bounceProgress) * 8.0;
              screenPoint = Offset(
                screenPoint.dx,
                screenPoint.dy - bounceOffset,
              );
            }
            
            // Improve visual quality by adjusting opacity based on Z position
            final zOpacityFactor = math.min(1.0, rotatedPoint.z * 1.5); // Emphasize front-facing hexagons
            
            // Add to the list with z-ordering
            continentPoints.add(_RegionHexPoint(
              screenPoint,
              region,
              rotatedPoint.z,
              hexagonSize,
              isActive: region == activeRegion,
              isHovered: region == hoveredRegion,
              bounceProgress: region == activeRegion ? bounceProgress : 0.0,
              opacityFactor: zOpacityFactor,
            ));
          }
        }
      }
      
      // Additional center hexagons with more detail
      final centerPoint3D = _lonLatTo3D(lon, lat);
      final rotatedCenterPoint = _rotatePoint(centerPoint3D, rotationX, rotationY);
      
      if (rotatedCenterPoint.z > 0) {
        final screenCenter = _project3DPointToScreen(size, radius, center, rotatedCenterPoint);
        
        // Add a slightly larger, more prominent hexagon at the exact coordinate point
        continentPoints.add(_RegionHexPoint(
          screenCenter,
          region,
          rotatedCenterPoint.z,
          hexSize * 1.2 * math.sqrt(rotatedCenterPoint.z),
          isActive: region == activeRegion,
          isHovered: region == hoveredRegion,
          bounceProgress: region == activeRegion ? bounceProgress : 0.0,
          opacityFactor: 1.0, // Full opacity for center points
          isExactCoordinate: true, // Mark as an exact coordinate point
        ));
      }
    }
    
    // Sort points by z-order (back to front)
    continentPoints.sort((a, b) => a.zOrder.compareTo(b.zOrder));
    
    // Draw all the hexagons from back to front
    for (final point in continentPoints) {
      final baseColor = regionColors[point.region] ?? Colors.grey;
      
      // Modify color based on active/hover state and z-position
      Color hexColor = baseColor;
      double opacity = point.opacityFactor * 0.9; // Base opacity affected by z-position
      
      if (point.isActive) {
        // Brighter, more saturated color for active regions
        hexColor = _enhanceColor(baseColor);
        opacity = math.min(1.0, opacity + 0.15); // Increase opacity for active regions
      } else if (point.isHovered) {
        // Slightly enhanced color for hover
        hexColor = _brightenColor(baseColor, 0.2);
        opacity = math.min(1.0, opacity + 0.1); // Slightly increase opacity for hover
      }
      
      // Exact coordinate points get higher opacity and more saturation
      if (point.isExactCoordinate) {
        hexColor = HSLColor.fromColor(hexColor)
            .withSaturation(math.min(1.0, HSLColor.fromColor(hexColor).saturation + 0.15))
            .toColor();
        opacity = math.min(1.0, opacity + 0.2); // Make exact coordinates more visible
      }
      
      // Apply final opacity
      hexColor = hexColor.withOpacity(opacity);
      
      _drawHexagon(
        canvas, 
        point.screenPoint, 
        point.size, 
        hexColor,
        isHighlighted: point.isActive || point.isHovered || point.isExactCoordinate,
        bounceProgress: point.bounceProgress,
        isExactCoordinate: point.isExactCoordinate,
      );
    }
  }
  
  // Enhance a color for active regions
  Color _enhanceColor(Color color) {
    // Create a brighter, more saturated version
    final hsl = HSLColor.fromColor(color);
    return hsl
        .withLightness((hsl.lightness + 0.2).clamp(0.0, 1.0))
        .withSaturation((hsl.saturation + 0.2).clamp(0.0, 1.0))
        .toColor();
  }
  
  // Brighten a color by the given amount
  Color _brightenColor(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    return hsl
        .withLightness((hsl.lightness + amount).clamp(0.0, 1.0))
        .toColor();
  }
  
  void _drawSphereEdgeEffect(Canvas canvas, Size size, double radius) {
    final center = Offset(size.width / 2, size.height / 2);
    
    // Draw a subtle gradient overlay for ambient occlusion around edges
    final edgePaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.transparent,
          Colors.black.withOpacity(0.5),
        ],
        stops: const [0.8, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    
    canvas.drawCircle(center, radius, edgePaint);
    
    // Add a subtle highlight on the top-left for 3D effect
    final highlightPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.5, -0.5),
        radius: 1.0,
        colors: [
          Colors.white.withOpacity(0.2),
          Colors.transparent,
        ],
        stops: const [0.0, 0.6],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    
    canvas.drawCircle(center, radius, highlightPaint);
  }
  
  void _drawHexagon(
    Canvas canvas, 
    Offset center, 
    double size, 
    Color color, {
    bool isHighlighted = false,
    double bounceProgress = 0.0,
    bool isExactCoordinate = false,
  }) {
    final path = Path();
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    
    // Apply bounce effect to the hexagons (wave-like motion)
    double heightOffset = 0.0;
    if (bounceProgress > 0) {
      // A wave-like animation that starts strong and fades out
      heightOffset = math.sin(bounceProgress * math.pi * 3) * (1.0 - bounceProgress) * 3.0;
    }
    
    // Create hexagon points with potential animation offset
    for (int i = 0; i < 6; i++) {
      final angle = i * math.pi / 3;
      final x = center.dx + size * math.cos(angle);
      
      // Apply vertical offset based on angle to create wave effect
      final waveOffset = heightOffset * math.sin(angle * 2);
      final y = center.dy + size * math.sin(angle) + waveOffset;
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    
    path.close();
    canvas.drawPath(path, paint);
    
    // Draw hexagon border - with special styling for exact coordinate points
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke;
      
    if (isExactCoordinate) {
      // Exact coordinate points get a stronger, more visible border
      borderPaint.color = Colors.white.withOpacity(0.85);
      borderPaint.strokeWidth = isHighlighted ? 1.5 : 1.2;
    } else {
      borderPaint.color = isHighlighted ? Colors.white.withOpacity(0.7) : Colors.black12;
      borderPaint.strokeWidth = isHighlighted ? 1.2 : 0.5;
    }
    
    canvas.drawPath(path, borderPaint);
    
    // Add glow effect for highlighted hexagons
    if (isHighlighted) {
      final glowPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = isExactCoordinate ? 2.5 : 2.0;
      
      if (isExactCoordinate) {
        // Brighter glow for exact coordinates
        glowPaint.color = Colors.white.withOpacity(0.6);
        glowPaint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 5.0);
      } else {
        glowPaint.color = Colors.white.withOpacity(0.4);
        glowPaint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);
      }
      
      canvas.drawPath(path, glowPaint);
      
      // Add an extra pulsing inner highlight for active regions
      if (bounceProgress > 0 || isExactCoordinate) {
        final innerGlowOpacity = isExactCoordinate ? 
            0.4 : // Higher baseline opacity for exact coordinates
            (0.3 * bounceProgress);
            
        final innerGlowPaint = Paint()
          ..color = Colors.white.withOpacity(innerGlowOpacity)
          ..style = PaintingStyle.fill
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0);
        
        // Draw a slightly smaller hexagon for the inner glow
        final innerPath = Path();
        final innerScale = isExactCoordinate ? 0.8 : 0.7; // Larger inner glow for exact coordinates
        
        for (int i = 0; i < 6; i++) {
          final angle = i * math.pi / 3;
          final x = center.dx + size * innerScale * math.cos(angle);
          final y = center.dy + size * innerScale * math.sin(angle) + heightOffset * innerScale;
          
          if (i == 0) {
            innerPath.moveTo(x, y);
          } else {
            innerPath.lineTo(x, y);
          }
        }
        innerPath.close();
        canvas.drawPath(innerPath, innerGlowPaint);
      }
    }
  }
  
  // Convert longitude/latitude to 3D Cartesian coordinates
  Vector3 _lonLatTo3D(double lon, double lat) {
    // Convert to radians
    final lonRad = lon * math.pi / 180;
    final latRad = lat * math.pi / 180;
    
    // Convert to 3D coordinates on unit sphere
    final x = math.cos(latRad) * math.sin(lonRad);
    final y = math.sin(latRad);
    final z = math.cos(latRad) * math.cos(lonRad);
    
    return Vector3(x, y, z);
  }
  
  // Rotate a 3D point around X and Y axes
  Vector3 _rotatePoint(Vector3 point, double rotX, double rotY) {
    // First rotate around X axis
    final y1 = point.y * math.cos(rotX) - point.z * math.sin(rotX);
    final z1 = point.y * math.sin(rotX) + point.z * math.cos(rotX);
    
    // Then rotate around Y axis
    final x2 = point.x * math.cos(rotY) + z1 * math.sin(rotY);
    final z2 = -point.x * math.sin(rotY) + z1 * math.cos(rotY);
    
    return Vector3(x2, y1, z2);
  }
  
  // Project a 3D point onto the 2D screen
  Offset _project3DPointToScreen(Size size, double radius, Offset center, Vector3 point) {
    // Simple perspective projection
    const focalLength = 2.0;
    final zdepth = focalLength + point.z;
    
    // Project
    final x = center.dx + (point.x / zdepth) * radius;
    final y = center.dy + (point.y / zdepth) * radius;
    
    return Offset(x, y);
  }
  
  // Determine if a point on a sphere is visible and convert to screen coordinates
  Offset? _sphere3DToScreen(
    Size size,
    double radius,
    Offset center,
    Vector3 point,
    double rotX,
    double rotY,
  ) {
    // Apply rotation
    final rotatedPoint = _rotatePoint(point, rotX, rotY);
    
    // Only return points on the visible half of the sphere
    if (rotatedPoint.z <= 0) return null;
    
    // Project to screen space
    return _project3DPointToScreen(size, radius, center, rotatedPoint);
  }
  
  @override
  bool shouldRepaint(covariant True3DHexGridPainter oldDelegate) =>
      rotationY != oldDelegate.rotationY ||
      rotationX != oldDelegate.rotationX ||
      hoveredRegion != oldDelegate.hoveredRegion ||
      scale != oldDelegate.scale;
}

// Helper class for storing hexagon data with z-ordering and animation properties
class _RegionHexPoint {
  final Offset screenPoint;
  final String region;
  final double zOrder;
  final double size;
  final bool isActive;
  final bool isHovered;
  final double bounceProgress;
  final double opacityFactor; // Controls the opacity based on position
  final bool isExactCoordinate; // Whether this is an exact coordinate point
  
  _RegionHexPoint(
    this.screenPoint, 
    this.region, 
    this.zOrder, 
    this.size, {
    this.isActive = false,
    this.isHovered = false,
    this.bounceProgress = 0.0,
    this.opacityFactor = 1.0,
    this.isExactCoordinate = false,
  });
}
