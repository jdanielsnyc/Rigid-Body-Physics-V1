class Edge {
  
  private PVector base, end, max, vector; /* The base and end points of the edge 
  vector, the maximum projection vertex (support point) returned by the 
  getSupportPoint method, and the actual edge vector that stretches from 
  (base.x, base.y) to (end.x, end.y) */
  
  
  Edge(PVector base, PVector end, PVector max) {
    this.base = base.copy();
    this.end = end.copy();
    this.max = max.copy();
    vector = end.copy().sub(base);
  }
  
  
  void setBase(PVector newBase) {
    base = newBase.copy();
    vector = end.copy().sub(base);
  }
  
  
  PVector getBase() {
    return base.copy();
  }
  
  
  void setEnd(PVector newEnd) {
    end = newEnd.copy();
    vector = end.copy().sub(base);
  }
  
  
  PVector getEnd() {
    return end.copy();
  }
  
  
  PVector getMax() {
    return max.copy();
  }
  
  
  PVector getVector() {
    return vector;
  }
}