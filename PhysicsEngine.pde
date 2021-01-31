class World {
  
  ArrayList<Object> objects;
  ArrayList<Field> fields;
  float t, dt, SIconv, gravity;
  boolean pause = false;
  
  World() {
    objects = new ArrayList<Object>();
    fields = new ArrayList<Field>();
    t = 0;
    dt = 0.0166666666667; // IN CASE WE DON'T GET ADAPTIVE DT WORKING, USE 30 FPS CAP AND 0.02 * 2 AS DT
    // dt = 0.02;
    SIconv = 30; // 1 meter = 30 pixels
    gravity = 9.81; // 9.81 m/s = 294.3 px/s
  }
  
  
  void run() {
    if (pause) {
      dt = 0;
    }
    else dt = 1/frameRate;
    
    for (Object o : objects) {
      o.colliding = false;
      for (Hitbox h : o.boxes) {
        h.colliding = false; // TEMP SOLUTION, WILL REFORMAT PROPERLY LATER
      }
    }
    calcPhysics();
    // Pos/Vel/Acc verlet should be handled inside the calcPhysics() function
    for (Field f : fields) {
      f.display();
    }
    for (int i = 0; i < objects.size(); i++) {
      Object o = objects.get(i);
      for (Hitbox h : o.boxes) {
        h.colliding = false; // TEMP SOLUTION, WILL REFORMAT PROPERLY LATER
      }
      if (i > 3 && !skeletonMode) {
        // don't display border walls
        o.display();
      }
      else if (skeletonMode && i > 3) {
        o.displayBoxes();
      }
    }
    
    // ADD RELATIVE VELOCITY TO THE INITIALIZATION PARAMETERES OF THE MANIFOLD OBJECT
  }
  
  
  private void calcPhysics() {
    
    ArrayList<Manifold[]> collisionList = getManifoldArray();
    resolveCollisions(collisionList);
    
    /*   || Verlet integration starts ||   */
    t += dt;
    
    PVector[] acc = new PVector[objects.size()];
    float[] aAcc = new float[objects.size()];
    for (int i = 0; i < objects.size(); i++) {
      Object o = objects.get(i);
      PVector force = calcForces(o);
      acc[i] = force.mult(SIconv * o.invMass());
      aAcc[i] = o.getAngularAcc();
    }

    for (int i = 0; i < objects.size(); i++) {
      Object o = objects.get(i);
      PVector dPos = (o.getVel().add(acc[i].copy().mult(dt/2))).mult(dt);
      o.adjustPos(dPos.x, dPos.y);
      o.adjustAngle((o.getAVel() + (aAcc[i]*dt/2))*dt);
    }
    
    PVector[] newAcc = new PVector[objects.size()];
    float[] newAngularAcc = new float[objects.size()];
    for (int i = 0; i < objects.size(); i++) {
      Object o = objects.get(i);
      PVector force = calcForces(o);
      newAcc[i] = force.mult(SIconv * o.invMass()); // Calc newAcceleration from forces
      newAngularAcc[i] = o.getAngularAcc();
      
      o.setAcc(newAcc[i]);
      o.setAngularAcc(newAngularAcc[i]);
    }
    
    for (int i = 0; i < objects.size(); i++) {
      Object o = objects.get(i);
      o.adjustVel((acc[i].copy().add(newAcc[i])).mult(dt/2));
      o.adjustAVel((aAcc[i] + newAngularAcc[i])*dt/2);
    }
    /*   || Verlet integration ends ||   */
 
  }
  
  
  private PVector calcForces(Object o) {
    PVector force = new PVector(0, gravity * o.mass()); // Force of gravity
    force.add(o.getEngine()); // Object self-propulsion
    
    if (o.mass() != -1) {
      for (Field f : fields) {
        // Force from fields 
        if (f.isPoint()) {
          force.add(f.getForce(o));
        }
        else {
          for (Hitbox h : o.getBoxes()) {
            String type = "";
            if (h.getType() == "round") {
              type = "round-poly";
            }
            else type = "poly-poly";
            PVector MTV = getCollisionData(h, f.getBox(), type).copy();
            if (MTV.x != 0 || MTV.y != 0) {
              force.add(f.getForce(o));
            }
          }
        }
      }
    }
    
    return force.copy();
  }
  
  
  private ArrayList<Manifold[]> getManifoldArray() {
    /* Builds an ArrayList of collision manifold arrays, where each array holds data about a collision between two objects. 
    The ArrayList is then sorted in a spe*/
    
    ArrayList<Manifold[]> collisionList = new ArrayList<Manifold[]>();
    
    /* Data from a collision between two objects is stored as an an array of contact manifolds, where each manifold 
    is a distinct area at which the two objects are touching/colliding. A manifold array is generated for every pair
    of colliding objects, and all of the manifold arrays are stored within the collisionList ArrayList. */
    for (int i = 0; i < objects.size() - 1; i++) {
      for (int j = i + 1; j < objects.size(); j++) {
        Manifold[] manifolds = getManifolds(objects.get(i), objects.get(j)); 
        if (manifolds.length > 0) {
          for (Manifold m : manifolds) {
            m.setID(new PVector(i, j)); 
            // First ID value: index of object A in objects, Second ID value: index of object B in objects
          }
          collisionList.add(manifolds);
        }
      }
    }
    
    /* This for loop reorders the manifold arrays in collisionList from greatest to least relative velocity. If an array 
    holds multiple contact manifolds, the array's relative velocity is considered to be that of the manifold with the 
    greatest average relative velocity. */
    PVector[] properManifoldIndices = new PVector[collisionList.size()]; 
    for (int i = 0; i < collisionList.size(); i++) {
      /* Here, we create an array of PVectors representing the manifold arrays in collisionList. The first value of each
      PVector is the magnitude of the relative velocity of the corresponding manifold array (see previous comment), while 
      the second value is the original position of that manifold array in collisionList. This array will be sorted by 
      relative velocity from greatest to least, then used to sort collisionList in the same manner. */
      float maxRelV = collisionList.get(i)[0].getRelV().mag();
      for (Manifold m : collisionList.get(i)) {
        // Determine the greatest average relative velocity out of all manifolds in the current manifold array
        float newRelV = m.getRelV().mag();
        if (newRelV > maxRelV) {
          maxRelV = newRelV;
        }
      }
      properManifoldIndices[i] = new PVector(maxRelV, i);
    }
    
    boolean sorted = false;
    while (!sorted) {
      // Sorting the properManifoldIndices array
      sorted = true;
      for (int i = 0; i < properManifoldIndices.length - 1; i++) {
        if (properManifoldIndices[i].x < properManifoldIndices[i + 1].x) {
          sorted = false;
          PVector temp = properManifoldIndices[i].copy();
          properManifoldIndices[i] = properManifoldIndices[i + 1];
          properManifoldIndices[i + 1] = temp;
        }
      }
    }
    
    for (int i = 0; i < collisionList.size(); i++) {
      // Reordering collisionList based on the sorted properManifoldIndices array
      int originalIndex = int(properManifoldIndices[i].y); // The original position in collisionList of the Manfiold array that properManifoldIndices[i] represents
      if (originalIndex != i) { // If the manifold array in collisionList is not in the proper ordered position as determined by the orignalValues array
        // NOTE: i is the proper index in collisionList at which collisionList[originalIndex] should be located
        Manifold[] temp = collisionList.get(i);
        collisionList.set(i, collisionList.get(originalIndex));
        collisionList.set(originalIndex, temp);
      }
    }
    
    for (int i = 0; i < collisionList.size(); i++) {
      for (Manifold m : collisionList.get(i)) {
        PVector currentID = m.getID();
        m.setID(new PVector(currentID.x, currentID.y, i)); // Third ID value: index of the manifold group in collisionList
      }
    }
    return collisionList;
  }
  
  
  private void resolveCollisions(ArrayList<Manifold[]> manifolds) {
  
    for (Manifold[] mArray : manifolds) {
      // Calc impulses
      Object objA = objects.get(int(mArray[0].getID().x));
      Object objB = objects.get(int(mArray[0].getID().y));
      float e = 0;
      if (objA.mass() == -1) {
        e = objB.getE();
      }
      else if (objB.mass() == -1) {
        e = objA.getE();
      }
      else e = (objA.getE() + objB.getE()) * 0.5;
      
      float totalImpulse = 0;
      float weightingTotal = 0;
      int truePoints = 0; // The number of collision points for which we consider collisions
      for (Manifold m : mArray) {
        if (m.getImpactDirection() <= 0) {
          weightingTotal -= m.getImpactDirection(); 
          // Values are subtracted because they are all negative (and we want weightingTotal to be positive)
          truePoints++;
        }
      }
      
      if (weightingTotal == 0) {
        // If weightingTotal == 0, that means that the relativeVelocity of the two objects is 0. In that case, we weight each collision point equally.
        weightingTotal = mArray.length;
      }
      
      PVector adjustmentNormal = new PVector(0, 0);
      PVector adjustmentPoint = new PVector(0, 0);
      boolean falseCollision = true; 
      // Will stay true if the objects are colliding but moving away from each other at all collision points
      ArrayList<PVector> MTVs = new ArrayList <PVector>();
      
      PVector[][] frictionImpulses = new PVector[truePoints][]; // Array holds the following data: [0] = impulse [1] = collision point
      float[] weightings = new float[truePoints];
      
      int trueCollisionCounter = -1;
      for (Manifold m : mArray) {
        PVector MTV = m.getNormal().mult(m.getDepth());
        MTVs.add(MTV.copy());
        // See the proofs of the formulas used for impulse resolution here: http://chrishecker.com/images/e/e7/Gdmphys3.pdf
        float impactDot = m.getImpactDirection();
        if (impactDot > 0) {
          // If the objects are already moving away from each other at p
          continue;
        }
        falseCollision = false;
        trueCollisionCounter++;
        PVector relV = m.getRelV();
        PVector n = m.getNormal();
        PVector p = m.getPoint();
        PVector radA = PVector.sub(p, objA.getCOM()); // Radius from the COM of objA to p
        PVector radB = PVector.sub(p, objB.getCOM()); // Radius from the COM of objB to p
        radA.set(-radA.y, radA.x);
        radB.set(-radB.y, radB.x);
        stroke(20);
        float w;
        if (weightingTotal == 0) {
          w = 1/weightingTotal;
          adjustmentNormal.add(n.copy());
          adjustmentPoint.add(p.copy());
        }
        else {
          w = (-impactDot / weightingTotal);
          // The percentage added of this point's calculated impulse is equal to the percent of the initial impact that the point supported
          adjustmentNormal.add(n.copy().mult(-impactDot));
          adjustmentPoint.add(p.copy().mult(-impactDot));
        }
        
        // Collision resolution impulse calculation
        float j = (-(1 + e) * relV.dot(n)) / ((n.dot(n) * (objA.invMass() + objB.invMass())) + (pow(radA.dot(n), 2) * objA.invMoment()) + (pow(radB.dot(n), 2) * objB.invMoment())); // collision impulse
        // float j = (-(1 + e) * relV.dot(n)) / ((n.dot(n) * (objA.invMass() + objB.invMass()))); // collision impulse but we don't consider the angular effects in calculation
        totalImpulse += (j * w);
        
        // Frictional impulse calculation
        PVector t = m.getTangent();
        if (relV.dot(t) > 0) {
          t.mult(-1); // Tangent must oppose relative velocity
        }
        float muS = sqrt(pow(objA.getMuS(), 2) + pow(objB.getMuS(), 2));
        // PVector 
        float jt = -relV.dot(t) / ((t.dot(t) * (objA.invMass() + objB.invMass())) + (pow(radA.dot(t), 2) * objA.invMoment()) + (pow(radB.dot(t), 2) * objB.invMoment()));; // Friction impulse
        PVector frictionImpulse;
        // Source: https://gamedevelopment.tutsplus.com/tutorials/how-to-create-a-custom-2d-physics-engine-friction-scene-and-jump-table--gamedev-7756
        if (abs(jt) < abs(j * muS)) {
          frictionImpulse = t.copy().mult(jt);
        }
        else {
          float muK = sqrt(pow(objA.getMuK(), 2) + pow(objB.getMuK(), 2));
          frictionImpulse = t.copy().mult(abs(j) * muK);
        }
      
        PVector[] frictionImpulseArray = {frictionImpulse, p.copy()};
        frictionImpulses[trueCollisionCounter] = frictionImpulseArray;
        weightings[trueCollisionCounter] = w;
      }
      
      if (!falseCollision) {
        
        // Adjusting the velocities of the colliding objects to separate them
        adjustmentNormal.normalize();
        adjustmentPoint.div(weightingTotal);
        PVector radA = PVector.sub(adjustmentPoint, objA.getCOM());
        PVector radB = PVector.sub(adjustmentPoint, objB.getCOM());
        radA.set(-radA.y, radA.x);
        radB.set(-radB.y, radB.x);
        PVector directedImpulse = adjustmentNormal.mult(totalImpulse);
        
        objA.adjustVel(directedImpulse.copy().mult(objA.invMass()));
        objB.adjustVel(directedImpulse.copy().mult(-objB.invMass()));
        objA.adjustAVel(directedImpulse.dot(radA.mult(objA.invMoment())));
        objB.adjustAVel(-directedImpulse.dot(radB.mult(objB.invMoment())));
        
        //println(directedImpulse);
        
        // Adding the effects of friction to the colliding objects
        for (int i = 0; i < frictionImpulses.length; i++) {
          PVector impulse = frictionImpulses[i][0].copy().mult(weightings[i]);
          PVector p = frictionImpulses[i][1];
          
          PVector radiusA = PVector.sub(p, objA.getCOM());
          PVector radiusB = PVector.sub(p, objB.getCOM());
          radiusA.set(-radiusA.y, radiusA.x);
          radiusB.set(-radiusB.y, radiusB.x);
          
          objA.adjustVel(impulse.copy().mult(objA.invMass()));
          objB.adjustVel(impulse.copy().mult(-objB.invMass()));
          objA.adjustAVel(impulse.dot(radiusA.mult(objA.invMoment())));
          objB.adjustAVel(-impulse.dot(radiusB.mult(objB.invMoment())));
          
          // 1. ENSURE THAT FRICTION IMPULSE CAN'T REVERSE DIRECTION (ONLY NEED A SYSTEM TO CHECK FOR LINEAR, NOT ANGULAR VELOCITY)
        }
        
        // Sorting MTVs by their angle of rotation from least to greatest (from -π to π)
        boolean sorted = false;
        while (!sorted) {
          sorted = true;
          for (int i = 0; i + 1< MTVs.size(); i++) {
            if (MTVs.get(i).heading() > MTVs.get(i + 1).heading()) {
              PVector temp = MTVs.get(i).copy();
              MTVs.get(i).set(MTVs.get(i + 1));
              MTVs.get(i + 1).set(temp);
              sorted = false;
            }
          }
        }
      }
      
      while(MTVs.size() > 1) {
        // Create a new MTV that covers as much as possible of all of the translations described by the other MTVs
        ArrayList<PVector> reductionArray = new ArrayList<PVector>(); // New ArrayList will be shorter than MTVs by one
        for (int i = 0; i < MTVs.size() - 1; i++) {
          PVector A = MTVs.get(i), B = MTVs.get(i + 1);
          if (PVector.angleBetween(A, B) <= PI/2) {
            if (A.dot(B.copy().normalize()) >= B.mag()) { // If a translation by vector A covers the entirety of a translation by vector B
              reductionArray.add(A.copy()); 
              // A combined MTV composed of two MTVs adjacent to each other in the MTVs ArrayList
            }
            else if (B.dot(A.copy().normalize()) >= A.mag()) { // If a translation by vector B covers the entirety of a translation by vector A
              reductionArray.add(B.copy()); 
            }
            else {
              reductionArray.add(lineIntersection(A.copy(), A.copy().add(-A.y, A.x), B.copy(), B.copy().add(B.y, -B.x)));
              /* If we say that all MTVs are vectors with basepoints at (0, 0), this new interpolated MTV is defined as the 
              vector stretching from (0, 0) to the intersection of two lines perpedincular to A and B, respectively, which 
              also intersect (A.x, A.y) and (B.x, B.y), respectively. This formula only applies to MTVs with an angle of 
              separation <= 90 degrees. */
            }
          }
          else reductionArray.add(new PVector((A.x + B.x)/2, (A.y + B.y)/2)); // For MTVs with an angle of separation > 90 degrees, we simply use their average as their combination
        }
        MTVs = reductionArray;
      }
      PVector newMTV = MTVs.get(0);
      float slop = 0.2;
      float percent = 0.8;
      
      if (newMTV.mag() > slop) {
        newMTV.mult(percent);
        float totalTranslationWeight = objA.invMass() + objB.invMass();
        PVector ACorrection;
        PVector BCorrection;
        if (totalTranslationWeight == 0) {
          ACorrection = newMTV.copy().mult(0.5);
          BCorrection = newMTV.copy().mult(-0.5);
        }
        else {
          ACorrection = newMTV.copy().mult(objA.invMass() * (1/totalTranslationWeight));
          BCorrection = newMTV.copy().mult(-objB.invMass() * (1/totalTranslationWeight));
        }
        objA.adjustPos(ACorrection.x, ACorrection.y);
        objB.adjustPos(BCorrection.x, BCorrection.y);
    }
    // println("MTV [FINAL]: " + (newMTV)); // CHECK ON MTV BUG WITH PARALLEL INTERPOLATION LINES
    }
  }
  
  
  private Manifold[] getManifolds(Object objA, Object objB) { // in physicsEngine class
  
    /* Determines if two objects are colliding. If they are, the method calculates various data points about 
    the collision, including contact normal (MTV), collision points, etc. */
    
    ArrayList<Manifold> tempManifoldArray = new ArrayList<Manifold>();
    boolean testComponents = false; // For testing purposes, displays various components such as MTV, incident edge, etc.
    
    if (objA.mass() == -1 && objB.mass == -1) {
      // If both objects have a mass of -1 don't consider their collision
      return new Manifold[0];
    }
    
    int iA = -1, iB = -1;
    for (Hitbox A : objA.getBoxes()) {
      iA++;
      for (Hitbox B : objB.getBoxes()) {
        iB++;
        
        Hitbox boxA = A;
        Hitbox boxB = B;
        
        Manifold mani;
        
        // DO BROAD PHASE WITH QUANDRANTS HERE, IF WE DON'T HAVE TWO HITBOXES IN THE SAME QUADRANT, CONTINUE;
        
        /*   || Collision type and MTV calculation begins ||   */
        String type = "";
        boolean boxesSwapped = false; // Used to check if boxA and boxB are swapped during a "round-poly" collision
     
        // Determines the collision type and rearranges hitboxes as needed
        if (boxA.getType().equals("poly") && boxB.getType().equals("poly")) {
          type = "poly-poly";
        }
        else if ((boxA.getType().equals("poly") && boxB.getType().equals("round"))
        || (boxA.getType().equals("round") && boxB.getType().equals("poly"))) {
          type = "round-poly";
          if (boxB.getType().equals("round")) {
            /* To simplify future calculations for round-poly collisions, 
            we always want boxA to be round-type and boxB to be poly-type. */
            boxA = B;
            boxB = A;
            boxesSwapped = true;
          }
        }
        else if (boxA.getType().equals("round") && boxB.getType().equals("round")) {
          type = "round-round";
        }
        PVector MTV = getCollisionData(boxA, boxB, type).copy();
        if (MTV.x == 0 && MTV.y == 0) {
          // println("BoxA: " + iA + ", BoxB: " + iB + ", Collision: False");
          continue;
        }
        else {
          // println("BoxA: " + iA + ", BoxB: " + iB + ", Collision: True");
          boxA.setColliding(true);
          boxB.setColliding(true);
          objA.colliding = true;
          objB.colliding = true;
        }
        // Ensures that the MTV points from B to A
        if (type.equals("poly-poly")) {
          PVector properDirection = boxA.getVertAvg().copy().sub(boxB.getVertAvg());
          if (properDirection.dot(MTV) < 0) {
            MTV.mult(-1);
          }
        }
        else if (type.equals("round-poly")) {
          PVector properDirection;
          if (boxesSwapped) {
            properDirection = boxB.getVertAvg().copy().sub(boxA.getCP());
          }
          else properDirection = boxA.getCP().copy().sub(boxB.getVertAvg());
          if (properDirection.dot(MTV) < 0) {
            MTV.mult(-1);
          }
        }
        else if (type.equals("round-round")) {
          PVector properDirection = boxA.getCP().copy().sub(boxB.getCP());
          if (properDirection.dot(MTV) < 0) {
            MTV.mult(-1);
          }
        }
        /*   || Collision type and MTV calculation ends ||   *
        
        /*   || Poly-poly contact manifold generation begins ||   */
        if (type.equals("poly-poly")) {
          // For reference: http://www.dyn4j.org/2011/11/contact-points-using-clipping/
          PVector[] vertsA = boxA.getVerts();
          PVector[] vertsB = boxB.getVerts();
        
          // Incident and reference edge generation begins
          Edge edgeA = getBestEdge(vertsA, MTV.copy().mult(-1)); 
          /* The MTV points from B to A, but we want the best edge on A
          facing towards B, so we flip the MTV. */
          Edge edgeB = getBestEdge(vertsB, MTV.copy());
          Edge ref; // reference edge
          Edge inc; // incident edge
          String refBox; // tracks which Hitbox is the reference Hitbox (the Hitbox whose edge is the reference edge)
          if (abs(edgeA.getVector().dot(MTV)) <= abs(edgeB.getVector().dot(MTV))) {
            // The Edge that is most perpendicular to the MTV/collision normal is the reference edge
            ref = edgeA;
            inc = edgeB;
            refBox = "A";
          } else {
            ref = edgeB;
            inc = edgeA;
            refBox = "B";
          }
          // Incident and reference edge generation ends
          
          // Clipping begins
          PVector refv = ref.getVector(); // A vector representing the reference edge; has clockwise orientation
          PVector[] clippedPoints = clip(inc.getBase(), inc.getEnd(), ref.getBase(), refv); 
          clippedPoints = clip(clippedPoints[0], clippedPoints[1], ref.getEnd(), refv.copy().mult(-1));
          inc.setBase(clippedPoints[0]);
          inc.setEnd(clippedPoints[1]);
          if (testComponents) {
            // FOR TEST PURPOSES ONLY
            stroke(255, 0, 255);
            vector(inc.getBase().x, inc.getBase().y, inc.getVector());
            fill(255, 0, 255);
            ellipse(inc.getEnd().x, inc.getEnd().y, 5, 5);
            stroke(0, 255, 255);
            vector(ref.getBase().x, ref.getBase().y, refv);
            fill(0, 255, 255);
            ellipse(ref.getEnd().x, ref.getEnd().y, 5, 5);
          }
          
          PVector refNorm = new PVector(-refv.y, refv.x);
          stroke(255, 0, 0);
          refNorm.normalize();
          //vector(ref.getBase().x, ref.getBase().y, refNorm.copy().mult(20));
          //vector(ref.getEnd().x, ref.getEnd().y, refNorm.copy().mult(20));
          /* Here we determine which endpoints of the incident edge are past the reference
          edge (the border line) towards the center of the reference hitbox. p1Depth and
          p2Depth are the depths of the two endpoints, */
          float border = (project(refNorm, ref.getMax()));
          float p1Depth = project(refNorm, clippedPoints[0]) - border;
          float p2Depth = project(refNorm, clippedPoints[1]) - border;
          boolean includeP1 = true, includeP2 = true;
          // If an endpoint isn't past the reference edge (see above), we disregard it
          if (p1Depth < 0) {
            includeP1 = false;
          }
          if (p2Depth < 0) {
            includeP2 = false;
          }
          // If one endpoint penetrates farther into the reference shape than the other, we disregard the less deep point
          float error = 0.001; 
          /* Earlier operations create tiny inequalities in what 
          should be equal values, so we allow for a slight error 
          when determining if the two values are equal to/less
          than/greater than each other. */
          if (p1Depth - p2Depth > error) {
            includeP2 = false;
          }
          else if (p2Depth - p1Depth > error) {
            includeP1 = false;
          }
          
          if (refBox.equals("A")) {
            clippedPoints[0].sub(MTV.copy().normalize().mult(p1Depth/2));
            clippedPoints[1].sub(MTV.copy().normalize().mult(p2Depth/2));
          }
          else { // if refBox.equals("B")
            clippedPoints[0].add(MTV.copy().normalize().mult(p1Depth/2));
            clippedPoints[1].add(MTV.copy().normalize().mult(p2Depth/2));
          }
          /* Contact point is shifted slightly along the MTV (positioned at the MTV's midpoint), which helps minimize
          any discrepancies in the collision responses of each object, as if this shift were not implimented, the 
          contact point would rest exactly on the edge/corner of one of the objects, and therefore would also penetrate
          deeper into the other object. These factors would in turn decrease the accuracy of the collision point as an 
          estimation of the actual initial point of collision between the two objects. */
          
          if (includeP1 && includeP2) {
            PVector finalPoint = PVector.add(clippedPoints[0], clippedPoints[1]).div(2); // Average of the two contact points
            mani = new Manifold(finalPoint, max(p1Depth, p2Depth), MTV); // max(p1Depth, p2Depth) to account for the tiny errors described earlier
          }
          else if (includeP1) {
            PVector finalPoint = clippedPoints[0];
            mani = new Manifold(finalPoint, p1Depth, MTV);
          }
          else { // else if includeP2 only
            PVector finalPoint = clippedPoints[1];
            mani = new Manifold(finalPoint, p2Depth, MTV);
          }
          // Clipping ends
        }
        /*   || Poly-poly contact manifold generation ends ||   */
        
        /*   || Round-poly contact manifold generation begins ||   */
        else if (type.equals("round-poly")) {
          PVector contactPoint = new PVector(0, 0); 
          if (boxesSwapped) {
            contactPoint = boxA.getCP().copy().add(MTV.copy().normalize().mult(boxA.getRadius()));
            contactPoint.sub(MTV.copy().div(2)); 
          }
          else {
            contactPoint = boxA.getCP().copy().sub(MTV.copy().normalize().mult(boxA.getRadius()));
            contactPoint.add(MTV.copy().div(2)); 
          }
          /* Contact point is shifted slightly along the MTV (positioned at the MTV's midpoint), which helps minimize
          any discrepancies in the collision responses of each object, as if this shift were not implimented, the 
          contact point would rest exactly on the edge/corner of one of the objects, and therefore would also penetrate
          deeper into the other object. These factors would in turn decrease the accuracy of the collision point as an 
          estimation of the actual initial point of collision between the two objects. */
          float depth = MTV.mag();
          mani = new Manifold(contactPoint, depth, MTV);
        }
        /*   || Round-poly contact manifold generation ends ||   */
        
        /*   || Round-round contact manifold generation begins ||   */
        else { // if type.equals("round-round")
          PVector contactPoint = boxB.getCP().copy().add(MTV.copy().normalize().mult(boxB.getRadius()));
          contactPoint.sub(MTV.copy().div(2)); 
          /* Contact point is shifted slightly along the MTV (positioned at the MTV's midpoint), which helps minimize
          any discrepancies in the collision responses of each object, as if this shift were not implimented, the 
          contact point would rest exactly on the edge/corner of one of the objects, and therefore would also penetrate
          deeper into the other object. These factors would in turn decrease the accuracy of the collision point as an 
          estimation of the actual initial point of collision between the two objects. */
          float depth = MTV.mag();
          mani = new Manifold(contactPoint, depth, MTV);
        }
        /*   || Round-round contact manifold generation ends ||   */
        tempManifoldArray.add(mani);
      }
    }

    Manifold[] finalManifolds = new Manifold[tempManifoldArray.size()];
    for (int i = 0; i < tempManifoldArray.size(); i++) {
      finalManifolds[i] = tempManifoldArray.get(i);
      //  \/  Calculating total relative velocity  \/
      PVector linearRelV = objA.getVel().sub(objB.getVel());
      PVector aVelA = new PVector(0, 0, objA.getAVel());
      PVector aVelB = new PVector(0, 0, objB.getAVel());
      PVector p = finalManifolds[i].getPoint();
      PVector radiusA = p.copy().sub(objA.getCOM());
      PVector radiusB = p.copy().sub(objB.getCOM());
      PVector tangentialRelV = (aVelA.copy().cross(radiusA)).sub(aVelB.copy().cross(radiusB)); 
      // Difference in tangential velocity (from rotational velocity) between collision point p on each object 
      PVector totalRelV = linearRelV.copy().add(tangentialRelV);
      if (testComponents) { 
        stroke(0, 200, 0);
        vector(objA.getCOM().x, objA.getCOM().y, radiusA);
        vector(p.x, p.y, aVelA.copy().cross(radiusA));
        stroke(200, 0, 0);
        vector(objB.getCOM().x, objB.getCOM().y, radiusB);
        vector(p.x, p.y, aVelB.copy().cross(radiusB));
      }
      finalManifolds[i].setRelV(totalRelV);
    }
    return finalManifolds;
  }
  
  
  private PVector getCollisionData(Hitbox h1, Hitbox h2, String collisionType) {
    /* A method designed specifically for use with physics engine operations.
    Checks for a collision between two hitboxes and returns the minimum
    translation vector (MTV) to be used in further calculations. An MTV of 
    <0, 0> signifies no collision, while all other returns mean the 
    hitboxes are colliding. */
    
    PVector MTV = new PVector(0, 0);
   
    // Broad phase check
    
    // Narrow phase check
    float minOverlap = pow(10, 10); // Needs to be an unrealistically large number so any realstic overlap will be smaller
    
    // Test for collision between two polygonal (poly-type) hitboxes
    if (collisionType.equals("poly-poly")) {
      PVector[] h1Verts = h1.getVerts();
      PVector[] h1Norms = h1.getNorms();
      PVector[] h2Verts = h2.getVerts();
      PVector[] h2Norms = h2.getNorms();
      PVector[] separatingAxes = new PVector[h1Norms.length + h2Norms.length];
      // Combining h1Norms and h2Norms into one array
      for (int i = 0; i < h1Norms.length; i++) {
        separatingAxes[i] = h1Norms[i]; 
      }
      for (int i = h1Norms.length; i < h1Norms.length + h2Norms.length; i++) {
        separatingAxes[i] = h2Norms[i - h1Norms.length];
      }
    
      for (int i = 0; i < separatingAxes.length; i++) {
        boolean parallelAxis = false;
        for (int j = 0; j < i; j++) {
          // If we already checked a parallel edge, we don't need to do it again
          parallelAxis = (separatingAxes[i].copy().normalize() == separatingAxes[j].copy().normalize());
          if (parallelAxis == true) break;
        }
        if (!parallelAxis) {
          float[] h1Proj = hitboxProjection(separatingAxes[i], h1Verts);
          float[] h2Proj = hitboxProjection(separatingAxes[i], h2Verts);
          float h1min = h1Proj[0];
          float h1max = h1Proj[1];
          float h2min = h2Proj[0];
          float h2max = h2Proj[1];
          if (h1max < h2min || h2max < h1min) {
            /* To prove that two hitboxes are colliding, the program must
            iterate over every normal of both hitboxes. In order to 
            maximize efficiency, the method looks for proof that the
            hitboxes are NOT colliding, in this case, space between the 
            projections signifying a gap between hitboxes. If this is
            detected, the loop breaks, minimizing the number of 
            calculations necessary for a result. */
            MTV.set(0, 0);
            return MTV;
          }
          
          float[] projPoints = {h1min, h1max, h2min, h2max};
          float overlap = 0;
          projPoints = bubbleSort(projPoints);
          if ((projPoints[1] == h1min && projPoints[2] == h1max) 
          || (projPoints[1] == h2min && projPoints[2] == h2max)) {
            /* If one hitbox's projection is completely contained within the other's,
            the overlap between the two projections (which is equal to the length of 
            the contained projection) will be less than the MTV, which in this case is
            the minimum translation along the projection axis required to eliminate 
            any overlap between the two projections. In this situation, the magnitude 
            of the MTV is equal the overlap plus difference between either the minimum 
            or maximum points of the two overlaps. */
            overlap = abs(projPoints[2] - projPoints[1])
            + min(projPoints[1] - projPoints[0], projPoints[3] - projPoints[2]);
          }
          else overlap = abs(projPoints[2] - projPoints[1]);
          
          if (overlap < minOverlap) {
            minOverlap = overlap;
            MTV.set(separatingAxes[i].copy().mult(overlap));
          }
        }
      }
    }
    
    if (collisionType.equals("round-poly")) {
      PVector[] h2Verts = h2.getVerts();
      PVector[] h2Norms = h2.getNorms();
      PVector[] separatingAxes = new PVector[1 + h2Norms.length];
      for (int i = 0; i < h2Norms.length; i++) {
        separatingAxes[i] = h2Norms[i]; 
      }
      /* Separating axis theorem with a polygon and a circle must test
      both the normals of the polygon and one additional axis: the axis 
      between the closest polygon vertex to the circle's centerpoint 
      and the centerpoint itself. */ 
      int closestVertexIndex = 0;
      float minDistance = pow(10, 10);
      PVector cp = h1.getCP();
      for (int i = 0; i < h2Verts.length; i++) {
        // Finds the index of the closest vertex to the circle's centerpoint
        float dist = dist(h2Verts[i].x, h2Verts[i].y, cp.x, cp.y);
        if (dist < minDistance) {
          minDistance = dist;
          closestVertexIndex = i;
        }
      }
      // Add the new axis to the array of separating axes as the final axis
      separatingAxes[h2Norms.length] = new PVector(cp.x - h2Verts[closestVertexIndex].x, cp.y - h2Verts[closestVertexIndex].y);
      separatingAxes[h2Norms.length].normalize();
      for (int i = 0; i < separatingAxes.length; i++) {
        boolean parallelAxis = false;
        for (int j = 0; j < i; j++) {
          // If we already checked a parallel edge, we don't need to do it again
          parallelAxis = (separatingAxes[i].copy().normalize() == separatingAxes[j].copy().normalize());
          if (parallelAxis == true) break;
        }
        if (!parallelAxis) {
          float[] h1Proj = hitboxProjection(separatingAxes[i], cp, h1.getRadius());
          float[] h2Proj = hitboxProjection(separatingAxes[i], h2Verts);
          float h1min = h1Proj[0];
          float h1max = h1Proj[1];
          float h2min = h2Proj[0];
          float h2max = h2Proj[1];
          if (h1max < h2min || h2max < h1min) {
            /* To prove that two hitboxes are colliding, the program must
            iterate over every normal of both hitboxes. In order to 
            maximize efficiency, the method looks for proof that the
            hitboxes are NOT colliding, in this case, space between the 
            projections signifying a gap between hitboxes. If this is
            detected, the loop breaks, minimizing the number of 
            calculations necessary for a result. */
            MTV.set(0, 0);
            return MTV;
          }
          
          float[] projPoints = {h1min, h1max, h2min, h2max};
          float overlap = 0;
          projPoints = bubbleSort(projPoints);
          if ((projPoints[1] == h1min && projPoints[2] == h1max) 
          || (projPoints[1] == h2min && projPoints[2] == h2max)) {
            /* If one hitbox's projection is completely contained within the other's,
            the overlap between the two projections (which is equal to the length of 
            the contained projection) will be less than the MTV, which in this case is
            the minimum translation along the projection axis required to eliminate 
            any overlap between the two projections. In this situation, the magnitude 
            of the MTV is equal the overlap plus difference between either the minimum 
            or maximum points of the two overlaps. */
            overlap = abs(projPoints[2] - projPoints[1])
            + min(projPoints[1] - projPoints[0], projPoints[3] - projPoints[2]);
          }
          else overlap = abs(projPoints[2] - projPoints[1]);
          
          if (overlap < minOverlap) {
            minOverlap = overlap;
            MTV.set(separatingAxes[i].copy().mult(overlap));
          }
        }
      }
    }
    
    if (collisionType.equals("round-round")) {
      float radiusSum = h1.getRadius() + h2.getRadius(); // Sum of the radii of the hitboxes
      PVector separation = h2.getCP().sub(h1.getCP()); // Distance between the centerpoints of the hitboxes
      float penetrationDepth = radiusSum - separation.mag();
      if (penetrationDepth < 0) {
        MTV.set(0, 0);
      }
      else if (h1.getCP().equals(h2.getCP())) {
        /* If two round-type hitboxes share the same centerpoint, the method
        returns an MTV of (0, 0), which signifies no collision. This is obviously
        incorrect, so instead an MTV of random direction but proper magnitude
        is returned. */
        PVector direction = new PVector(random(-1, 1), random(-1, 1));
        MTV.set(direction.normalize().mult(penetrationDepth));
      }
      else {
        MTV.set(separation.normalize().mult(penetrationDepth));
      }
      
    }
    return MTV;
  }
  
  
  private float project(PVector axis, PVector vector) {
    return axis.copy().normalize().dot(vector);
  }
  
  
  private float[] hitboxProjection(PVector axis, PVector[] vertices) { // For poly-type hitboxes
    /* Iterates over each vertex, projecting them against an axis in
    order to create a 'mathematical shadow' of sorts. */
    float min = project(axis, vertices[0]);
    float max = min;
    for (int i = 1; i < vertices.length; i++) {
      float p = project(axis, vertices[i]);
      if (p < min) { 
        min = p; // Replaces the minimum if the new projection is smaller.
      } else if (p > max) {
        max = p; // Replaces the maximum if the new projection is larger.
      }
    }
    float[] projections = {min, max}; 
    return projections; /* returns an array of the both the minimum and maximum 
    projection values, which, geometrically speaking, represent the starting and 
    ending position, respectively, of the vector's "shadow" on the axis. */
  } 
  
  
  private float[] hitboxProjection(PVector axis, PVector cp, float radius) { // For round-type hitboxes
    /* Projects a round-type hitbox against an axis in order to 
    create a 'mathematical shadow' of sorts. */
    float midpoint = project(axis, cp);
    float min = midpoint - radius;
    float max = midpoint + radius;
    float[] projections = {min, max}; 
    return projections; /* returns an array of the both the minimum and maximum 
    projection values, which, geometrically speaking, the represent starting and 
    ending position, respectively, of the circle's "shadow" on the axis. */
  } 
  
  
  private int getSupportPoint(PVector[] vertices, PVector direction) {
    /* Returns the index of the 'support point' along a direction vector 
    from an array of vertices. The support point is defined as the farthest 
    vertex along that direction vector. */
    int index = 0;
    float max = vertices[0].dot(direction);
    for (int i = 1; i < vertices.length; i++) {
      float dist = vertices[i].dot(direction);
      if (dist > max) {
        index = i;
        max = dist;
      }
    }
    return index;
  }
  
  
  private Edge getBestEdge(PVector[] verts, PVector normal) {
    /* Calculates and returns the Edge involved in the collision
    of its hitbox. This Edge object is not to be confused with the 
    hitbox's edge vectors, which represent the sides/faces of the 
    hitbox. */ 
    normal.normalize();
    int len = verts.length;
    int spIndex = getSupportPoint(verts, normal);
    PVector sp = verts[spIndex].copy();
    int prevIndex = (spIndex - 1 + len) % len;
    // The index of the vertex 'behind' (behind meaning one vertex counterclockwise) the support point
    /* Adding len in the expression eliminates issues when spIndex = 0
    (and thus the modulo operand would normally have to work with a 
    negative dividend), but doesn't affect calculations when this is
    not the case, as it is cancelled out by the modulo. */
    int nextIndex = (spIndex + 1) % len;
    // The index of the vertex 'in front of' (in front of meaning one vertex clockwise) the support point
    PVector prev = sp.copy().sub(verts[prevIndex]); // A vector representing the hitbox edge vector 'behind' sp 
    PVector next = sp.copy().sub(verts[nextIndex]); // A vector representing the hitbox edge vector 'in front of' sp 
    /* Note: even though technically, the hitbox edge vector that 
    next represents should point away from sp, and not towards it
    (since all hitbox edges are oriented in the clockwise direction), 
    we want both vectors pointing towards sp for the sake of 
    calculations. However, when the Edge object is returned, the 
    edge vector returned will retain its original clockwise 
    orientation. */
    prev.normalize();
    next.normalize();
    /* The edge vector that is most perpendicular to the collision 
    normal will be returned as the hitbox's collision edge. To preserve
    the winding direction (clockwise) of the hitbox's vertices and edge
    vectors, the edge vector will be stored in its original orientation, 
    and the support point stored seperately. */
    if (abs(prev.dot(normal)) <= abs(next.dot(normal))) {
      /* The closer to 0 the dot product is, the more perpendicular
      the edge is to the normal. In this case, prev.dot(normal) is
      closer to 0, and therefore will be returned in the Edge object. */
      return new Edge(verts[prevIndex], sp, sp);
    } else {
      /* The closer to 0 the dot product is, the more perpendicular
      the edge is to the normal. In this case, next.dot(normal) is
      closer to 0, and therefore will be returned in the Edge object. */
      return new Edge(sp, verts[nextIndex], sp);
    }
  }
  
  
  private PVector[] clip(PVector p1, PVector p2, PVector boundPoint, PVector clipDirection) {
    /* 
    Terms: 
    Clip line: The line being clipped, which stretches from p1 to p2
    Clipping axis: The axis along which the clip line is being clipped (parallel to clipDirection)
    Clip border: An infinitely long line perpendicular to the clipDirection; represents the cutting point of the clip line
    Behind: In the negative direction from a point along the clipping axis
    In front of: In the positive direction from a point along the clipping axis
    */
    PVector[] clippedPoints = new PVector[2];
    float bound = project(clipDirection, boundPoint); // the position of the projection of boundPoint along the clipping axis
    float o1 = project(clipDirection, p1); // the position of the projection of p1 along the clipping axis
    float o2 = project(clipDirection, p2); // the position of the projection of p2 along the clipping axis
    if (o1 >= bound && o2 >= bound) {
      /* If both p1 and p2 are in front of the clip border, there's no 
      reason to clip the clip line, and we return the original line. */
      clippedPoints[0] = p1.copy();
      clippedPoints[1] = p2.copy();
    }
    else if (o1 < bound && o2 >= bound) {
      /* If p1 is behind the clip border and p2 is in front of it, we measure the 
      difference between o1 (the projection */
      PVector lineDirection = p2.copy().sub(p1).normalize();
      float clipAmount = abs(bound - o1) / cos(PVector.angleBetween(lineDirection, clipDirection)); 
      clippedPoints[0] = p1.copy().add(lineDirection.copy().mult(clipAmount));
      clippedPoints[1] = p2.copy();
    }
    else if (o2 < bound && o1 >= bound) {
      PVector lineDirection = p1.copy().sub(p2).normalize();
      float clipAmount = abs(bound - o2) / cos(PVector.angleBetween(lineDirection, clipDirection)); 
      clippedPoints[0] = p1.copy();
      clippedPoints[1] = p2.copy().add(lineDirection.copy().mult(clipAmount));
    }
    else {
      // If the entire clip line is behind the 
      float reallyBigNumber = pow(2, 22); 
      clippedPoints[0] = new PVector(reallyBigNumber, reallyBigNumber);
      clippedPoints[1] = new PVector(reallyBigNumber, reallyBigNumber);
    }
    return clippedPoints;
  }
  
  
  private float[] bubbleSort(float[] array) { 
    boolean arrayWasAdjusted = true;
    while(arrayWasAdjusted) {
      arrayWasAdjusted = false;
      for(int i = 0; i < array.length - 1; i++) {
        if (array[i] > array[i+1]) {
          float temp = array[i];
          array[i] = array[i+1];
          array[i+1] = temp;
          arrayWasAdjusted = true;
        }
      }
    }
    return array;
  }
  
  
  private boolean rectsOverlap(PVector tl1, PVector br1, PVector tl2, PVector br2) {
    if (tl1.x > br2.x || tl2.x > br1.x) {
      // if the left side of r1 is to the right of r2 or vice versa (horizontal gap between rects)
      return false;
    }
    if (tl1.y > br2.y || tl2.y > br1.y) {
      // if the top of r1 is below the bottom of r2 or vice versa (vertical gap between rects)
      return false;
    }
    
    // [ maybe have the hitboxes calculate this on movement/rotation? ]
    return true;
  }
  
  
  PVector lineIntersection(PVector A, PVector B, PVector C, PVector D) { 
  // Calculates the intersection point (if it exists) between two lines
  // I was too lazy to write this method my self, so here's the source for this method: https://www.geeksforgeeks.org/program-for-point-of-intersection-of-two-lines/
  
      // Line AB represented as a1x + b1y = c1 
      float a1 = B.y - A.y; 
      float b1 = A.x - B.x; 
      float c1 = a1*(A.x) + b1*(A.y); 
     
      // Line CD represented as a2x + b2y = c2 
      float a2 = D.y - C.y; 
      float b2 = C.x - D.x; 
      float c2 = a2*(C.x)+ b2*(C.y); 
     
      float determinant = a1*b2 - a2*b1; 
     
      if (determinant == 0) 
      { 
          // The lines are parallel. This is simplified 
          // by returning a pair of FLT_MAX 
          return new PVector(0, 0); 
      } 
      else
      { 
          float x = (b2*c1 - b1*c2)/determinant; 
          float y = (a1*c2 - a2*c1)/determinant; 
          return new PVector(x, y); 
      } 
  } 
  
  
  void addObj(Object newObj) {
    objects.add(newObj);
  }
  
  
  void addField(Field newField) {
    fields.add(newField);
  }
  
  
  void buildWalls() {
    // Creates the world borders preventing objects from moving off of the screen 
    PVector[] hBarrierPoints = {
      new PVector(0, 0),
      new PVector(2000, 0),
      new PVector(2000, 200),
      new PVector(0, 200)
    };
    
    PVector[] vBarrierPoints = {
      new PVector(0, 0),
      new PVector(200, 0),
      new PVector(200, 2000),
      new PVector(0, 2000)
    };
  
    topBorder = new Hitbox(hBarrierPoints);
    Hitbox[] topBox = {topBorder};
    PVector[] topOffsets = {new PVector(0, 0)};
    top = new Object(topBox, topOffsets);
    top.setPos(width/2, -100);
    top.setMass(-1);
    addObj(top);
    
    bottomBorder = new Hitbox(hBarrierPoints);
    Hitbox[] bottomBox = {bottomBorder};
    PVector[] bottomOffsets = {new PVector(0, 0)};
    bottom = new Object(bottomBox, bottomOffsets);
    bottom.setPos(width/2, height + 80);
    bottom.setMass(-1);
    addObj(bottom);
    
    leftBorder = new Hitbox(vBarrierPoints);
    Hitbox[] leftBox = {leftBorder};
    PVector[] leftOffsets = {new PVector(0, 0)};
    left = new Object(leftBox, leftOffsets);
    left.setPos(-100, height/2);
    left.setMass(-1);
    addObj(left);
    
    rightBorder = new Hitbox(vBarrierPoints);
    Hitbox[] rightBox = {rightBorder};
    PVector[] rightOffsets = {new PVector(0, 0)};
    right = new Object(rightBox, rightOffsets);
    right.setPos(width + 99, height/2);
    right.setMass(-1);
    addObj(right);
  }
  
  
  void clear() {
    objects.clear();
    fields.clear();
    buildWalls();
  }
  
  
  Object getObj(int i) {
    return objects.get(i);
  }
  
  
  Field getField(int i) {
    return fields.get(i);
  }
}
