class complexManifold {
  
  // A Manifold object stores all of the data concerning a collision between two hitboxes
  
  private PVector[] points, relVArray; // relV for each collision point p = total velocity of p on object A - total velocity of p on object B
  private PVector normal, tangent, avgRelV; // Collision normal, collision tangent (90˚ counterclockwise rotation of the normal), and average relative velocity
  private float[] ImpactDirection;
  private float depth, maxDepth; // Penetration depth, maximum penetration depth
  private int pointsNo; // The number of points that make up the manifold
  private PVector ID; 
  /* A ID that describes the objects whose collision is being described by the manifold, the first value is the index
  of the first colliding object, the second value is the index of the second colliding object. */
  
  complexManifold(PVector[] points, float depth, PVector MTV) {
    this.points = copyArray(points);
    this.depth = depth;
    normal = MTV.copy().normalize();
    tangent = new PVector(normal.y, -normal.x);
    maxDepth = MTV.mag();
    pointsNo = points.length;
    relVArray = new PVector[pointsNo];
    ImpactDirection = new float[pointsNo];
    ID = new PVector(-1, -1); // Default ID
  }
  
  
  PVector getID() {
    return ID.copy();
  }
  
  
  void setID(PVector newID) {
    ID = newID.copy();
  }
  
  
  PVector[] getPoints() {
    return copyArray(points);
  }
  
  
  PVector getNormal() {
    return normal.copy();
  }
  
  
  float getDepth() {
    return depth;
  }
  
  
  void setRelVArray(PVector[] newVels) {
    PVector average = new PVector(0, 0);
    for (int i = 0; i < newVels.length; i++) {
       relVArray[i] = newVels[i].copy();
       ImpactDirection[i] = normal.dot(relVArray[i].copy().normalize());
       average.add(relVArray[i]);
    }
    avgRelV = average.div(relVArray.length).copy();
  }
  
  
  PVector[] getRelVArray() {
    return copyArray(relVArray);
  }
  
  
  float[] getImpactDirection() {
    return ImpactDirection;
  }
  
  
  PVector getAvgRelV() {
    return avgRelV.copy();
  }
  
  
  int size() {
    return pointsNo;
  }
}