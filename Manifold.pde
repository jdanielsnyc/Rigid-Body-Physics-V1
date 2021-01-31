class Manifold {
  
  // A Manifold object stores all of the data concerning a collision between two hitboxes
  private PVector normal, tangent, point, relV; 
  // relV for each collision point p = total velocity of p on object A - total velocity of p on object B
  // Collision normal, collision tangent (90˚ counterclockwise rotation of the normal), and average relative velocity
  private float impactDirection;
  private float depth, maxDepth; // Penetration depth, maximum penetration depth
  private PVector ID; 
  /* A ID that describes the objects whose collision is being described by the manifold, the first value is the index
  of the first colliding object, the second value is the index of the second colliding object. */
  
  Manifold(PVector point, float depth, PVector MTV) {
    this.point = point.copy();
    this.depth = depth;
    normal = MTV.copy().normalize();
    tangent = new PVector(normal.y, -normal.x);
    maxDepth = MTV.mag();
    ID = new PVector(-1, -1); // Default ID
  }
  
  
  PVector getID() {
    return ID.copy();
  }
  
  
  void setID(PVector newID) {
    ID = newID.copy();
  }
  
  
  PVector getPoint() {
    return point.copy();
  }
  
  
  PVector getNormal() {
    return normal.copy();
  }
  
  
  PVector getTangent() {
    return tangent.copy();
  }
  
  
  float getDepth() {
    return depth;
  }
  
  
  PVector getRelV() {
    return relV.copy();
  }
  
  
  float getImpactDirection() {
    return impactDirection;
  }

  void setRelV(PVector relV) {
    this.relV = relV.copy();
    impactDirection = normal.dot(relV);
  }
}