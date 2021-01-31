class Hitbox {
  
  private PVector[] verts, edges, norms, offsets; // Arrays of vertices, edge vectors, edge normal vectors, and offset vectors
  // Note: edge, normal, and offset vectors describe length and direction, not position on the xy-plane
  private float cx, cy, angle; // The x and y positions of the point that the hitbox rotates around and the angle of rotation
  //Note: the point (cx, cy) is also considered the hitbox's position in the xy-plane
  private PVector vertAvg; // The point representing the average of all vertices
  private String type; // The type of hitbox, either "poly" or "round"
  private PVector cp, offset; // Centerpoint of a circular hitbox and the centerpoint's offset from (cx, cy)
  private float radius; 
  private boolean colliding;
  
  
  Hitbox(PVector[] verts) { 
    // Constructor for poly-type hitboxes
    type = "poly";
    colliding = false;
    angle = 0;
    
    // Note: points should be listed in clockwise order
    this.verts = new PVector[verts.length];
    for (int i = 0; i < verts.length; i++) {
      this.verts[i] = verts[i].copy();
    }
    edges = new PVector[verts.length]; 
    norms = new PVector[edges.length]; 
    offsets = new PVector[verts.length];
    vertAvg = new PVector(0, 0);
    calcVertAvg();
    cx = vertAvg.x;
    cy = vertAvg.y;
    calcEdges();
    calcNorms();
    calcOffsets();
    /* The vertex average is a close approximation of the center of 
    mass of a lamina of constant density, and therefore makes for 
    a both plausible and visually appealing center of rotation */
    
    // compatible types: poly
  }
  
  
  Hitbox(PVector cp, float radius) { 
    // Constructor for round-type hitboxes
    type = "round";
    colliding = false;
    angle = 0;

    this.cp = cp;
    this.radius = radius;
    cx = cp.x;
    cy = cp.y;
    calcOffsets();
    // compatible types: round
  }
  
  private void calcEdges() {
    // Defines vectors representing the edges of the hitbox
    for (int i = 0; i < edges.length; i++) {
      int endpointIndex = (i + 1) % (edges.length);
      edges[i] = verts[endpointIndex].copy().sub(verts[i]);
    }
    // compatible types: poly
  }
  
  
  private void calcNorms() {
    // Defines vectors representing the normal of each edge
    for (int i = 0; i < norms.length; i++) {
      norms[i] = new PVector(edges[i].y, -edges[i].x);
      norms[i].normalize();
    }
    // compatible types: poly
  }
  
  
  private void calcOffsets() {
    /* For poly: Defines 'offset vectors' representing the distance 
    between each vertex and the hitbox's xy-position (cx, cy)
    
    For round: Calculates the distance between the centerpoint and
    the hitbox's xy-position (cx, cy) */
    if (type.equals("poly")) {
      for (int i = 0; i < verts.length; i++) {
        offsets[i] = new PVector(verts[i].x - cx, verts[i].y - cy);
      }
    }
    else if (type.equals("round")) {
      offset = new PVector(cp.x - cx, cp.y - cy);
    }
    // compatible types: poly, round
  }
  
  
  private void calcVertAvg() {
    PVector sum = new PVector(0, 0);
    for (PVector item : verts) {
      sum.add(item);
    }
    PVector avg = sum.div(verts.length);
    vertAvg.set(avg.x, avg.y);
    // compatible types: poly
  }
  
  
  void setPos(float x, float y) {
    /* Sets the position of the entire hitbox, moving both the
    hitbox's center and the hitbox itself (vertices and edges) */
    cx = x;
    cy = y;
    if (type.equals("poly")) {
      for (int i = 0; i < verts.length; i++) {
        verts[i] = new PVector(cx + offsets[i].x, cy + offsets[i].y);
      }
      calcVertAvg();
    }
    else if (type.equals("round")) {
      cp.set(cx + offset.x, cy + offset.y);
    }
    // compatible types: poly, round
  }
  
  
  void adjustPos(float dx, float dy) {
    setPos(cx + dx, cy + dy);
    // compatible types: poly, round
  }
  
  
  void setCenter(float cx, float cy) {
    /* Sets the position of only the hitbox's center while adjusting the 
    offsets to ensure that the hitbox itself (vertices/edges/centerpoint) 
    remains at the same position in the plane */
    this.cx = cx;
    this.cy = cy;
    calcOffsets();
    // compatible types: poly, round
  }
  
  
  void adjustCenter(float dcx, float dcy) {
    setCenter(cx + dcx, cy + dcy);
    // compatible types: poly, round
  }
  
  
  void setCenterRelativeToAvg(float cx, float cy) {
    // Sets the position of the hitbox's center relative to the hitbox's vertex average
    resetCenter();
    adjustCenter(cx, cy);
    // compatible types: poly
  }
  
  
  void adjustAngle(float dtheta) {
    angle += dtheta;
    if (type.equals("poly")) {
      for (int i = 0; i < verts.length; i++) {
        float vx = verts[i].x;
        float vy = verts[i].y;
        float vxNew = (vx - cx) * cos(dtheta) - (vy - cy) * sin(dtheta) + cx;
        float vyNew = (vy - cy) * cos(dtheta) + (vx - cx) * sin(dtheta) + cy;
        verts[i].set(vxNew, vyNew);
      }
      calcEdges();
      calcNorms();
    }
    else if (type.equals("round")) {
      float cpxNew = (cp.x - cx) * cos(dtheta) - (cp.y - cy) * sin(dtheta) + cx;
      float cpyNew = (cp.y - cy) * cos(dtheta) + (cp.x - cx) * sin(dtheta) + cy;
      cp.set(cpxNew, cpyNew);
    }
    calcOffsets();
    // compatible types: poly, round
  }
  
  
  PVector[] getVerts() {
    PVector[] vertsCopy = new PVector[verts.length];
    for (int i = 0; i < verts.length; i++) {
      vertsCopy[i] = verts[i].copy();
    }
    return vertsCopy;
    // compatible types: poly
  }
  
  
  PVector[] getEdges() {
    PVector[] edgesCopy = new PVector[edges.length];
    for (int i = 0; i < verts.length; i++) {
      edgesCopy[i] = edges[i].copy();
    }
    return edgesCopy;
    // compatible types: poly
  }
  
  
  PVector[] getNorms() {
    PVector[] normsCopy = new PVector[norms.length];
    for (int i = 0; i < verts.length; i++) {
      normsCopy[i] = norms[i].copy();
    }
    return normsCopy;
    // compatible types: poly
  }
  
  
  PVector getPos() {
    return new PVector(cx, cy);
    // compatible types: poly, round
  }
  
  
  PVector getVertAvg() {
    return vertAvg.copy();
    // compatible types: poly
  }
  
  
  String getType() {
    return type;
    // compatible types: poly, round
  }
  
  
  PVector getCP() {
    return cp.copy();
    // compatible types: round
  }
  
  
  float getRadius() {
    return radius;
    // compatible types: round
  }
  
  
  void resetCenter() {
    if (type.equals("poly")) {
      calcVertAvg();
      setCenter(vertAvg.x, vertAvg.y);
    }
    else if (type.equals("round")) {
      setCenter(cp.x, cp.y);
    }
    // compatible types: poly, round
  }
  
  
  void setColliding(boolean colliding) {
    this.colliding = colliding;
  }
  
  
  boolean isColliding() {
    return colliding;
  }
  
  
  Hitbox copy() {
    Hitbox copy;
    if (type.equals("poly")) {
      copy = new Hitbox(verts);
      copy.setCenterRelativeToAvg(cx - vertAvg.x, cy - vertAvg.y);
      copy.setPos(cx, cy);
      copy.adjustAngle(angle);
    }
    else { // if type.equals("round") 
      copy = new Hitbox(cp.copy(), radius);
      copy.setCenterRelativeToAvg(cx - vertAvg.x, cy - vertAvg.y);
      copy.setPos(cx, cy);
      copy.adjustAngle(angle);
    }
    return copy;
  }
  
  
  void drawBox() {
    boolean e = true, v = false, c = true;
    if (getType().equals("poly")) {
      PVector[] verts = getVerts();
      PVector[] edges = getEdges();
      if (e) {
        for (int i = 0; i < verts.length; i++) {
          // Edges
          stroke(0, 225, 225);
          if (colliding) {
            stroke(100, 100, 225);
          }
          line(verts[i].x, verts[i].y, 
          verts[i].x + edges[i].x, verts[i].y + edges[i].y);
        }
      }
      
      if (v) {
        for (PVector vertex : verts) {
          // Vertices
          noStroke();
          fill(190, 0, 0);
          if (colliding) {
            fill(100, 100, 225);
          }
          ellipse(vertex.x, vertex.y, 8, 8);
          fill(225);
          ellipse(vertex.x, vertex.y, 6, 6);
        }
      }
    }
    else if (getType().equals("round")) {
      noFill();
      stroke(225, 0, 0, 100);
      if (colliding) {
        stroke(100, 100, 225, 100);
      }
      ellipse(cp.x, cp.y, 2*radius, 2*radius);
      line(cx, cy, cx + radius*cos(angle), cy + radius*sin(angle));
    }
    
    if (c) {
      // Center
      PVector center = getPos();
      noFill();
      stroke(150, 0, 0);
      if (colliding) {
        stroke(40, 40, 190);
      }
      ellipse(center.x, center.y, 8, 8); 
    }
  }
  
  
  void drawNormals() {
    PVector[] vertices = getVerts();
    PVector[] normals = getNorms();
    PVector ep1, ep2; // End points of the normal vector arrow
    float normSize = 35;
    stroke(190, 0, 0);
    for (int i = 0; i < vertices.length; i++) {
      // Normal
      PVector basePoint = vertices[i].copy().add(vertices[(i + 1) % vertices.length]).div(2); // average between two vertices
      PVector normEnd = basePoint.copy().add(normals[i].copy().mult(normSize));
      line(basePoint.x, basePoint.y, normEnd.x, normEnd.y);
      
      // Arrow
      ep1 = normals[i].copy().mult(normSize * 0.9);
      ep2 = ep1.copy();
      ep1.rotate(PI/40);
      ep2.rotate(-PI/40);
      line(normEnd.x, normEnd.y, basePoint.x + ep1.x, basePoint.y + ep1.y);
      line(normEnd.x, normEnd.y, basePoint.x + ep2.x, basePoint.y + ep2.y);
    }
  }
}