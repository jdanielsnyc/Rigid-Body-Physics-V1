  class Object {
  
  // START WORKING WITH OBJECTS AND MULTI-HITBOX SYSTEMS
  /* FOR MULTIPLE MTVs, PROJECT THEM ALL ON EACH OTHER AND ADD 
  WHAT'S NEEDED TO CLEAR THE OTHER MTVs ALONG ONE OF THE MTVs'
  PROJECTIONS */
  
  private Hitbox[] boxes; //c Array of all of the object's hitboxes
  private float mass, invMass, charge, angle, aVel, aAcc, moment, invMoment, elasticity, muS, muK;
  private String type, name;
  private PVector pos, vel, acc, COM, topleft, bottomright, frictionForce, imageOffset, engineForce; // NOTE: COM = Center of Mass
  private PVector[] offsets;
  // topleft and bottomright define the bounding rectangle used for broad phase collision detection
  private boolean immovable, colliding;
  private PImage sprite;
  
  Object (Hitbox[] boxes, PVector[] offsets) {
    this.boxes = boxes;
    mass = 100; // kg
    invMass = 1/mass;
    charge = 100;
    angle = 0;
    aVel = 0;
    aAcc = 0;
    moment = 1000000; // kg px^2
    invMoment = 1/moment;
    elasticity = 1;
    muS = 0.3;
    muK = muS*0.6;
    
    pos = new PVector(0, 0);
    vel = new PVector(0, 0);
    acc = new PVector(0, 0);
    COM = new PVector(0, 0);
    topleft = new PVector(0, 0);
    bottomright = new PVector(0, 0);
    immovable = false;
    
    type = "default";
    name = "object";
    
    /* NOTE: Offsets are defined in relation to the average 
    point of a hitbox. For example, an offset of (80, 0) means 
    the average point of the hitbox is 80 pixels to the right 
    of the object's center of mass. */
    
    // Positioning all hitboxes relative to the center of mass
    this.offsets = offsets;
    for (int i = 0; i < offsets.length; i++) {
      boxes[i].setCenterRelativeToAvg(-offsets[i].x, -offsets[i].y);
      boxes[i].setPos(COM.x, COM.y);
    }
    
    engineForce = new PVector(0, 0);
  }
  
  
  void initializeSprite(PImage sprite, PVector imageOffset) {
    this.sprite = sprite;
    this.imageOffset = imageOffset.copy();
  }
  
  
  Hitbox[] getBoxes() {
    return boxes;
  }
  

  PVector getPos() {
    return pos.copy();
  }


  void setPos(float x, float y) {
    pos.set(x, y);
    COM.set(x, y);
    for (Hitbox h : boxes) {
      h.setPos(COM.x, COM.y);
    }
  }
  
  
  void adjustPos(float dx, float dy) {
    setPos(pos.x + dx, pos.y + dy);
  }
  
  
  PVector getVel() {
    return vel.copy();
  }
  
  
  void setVel(PVector newVel) {
    vel.set(newVel.x, newVel.y);
  }
  
  
  void adjustVel(PVector dVel) {
    vel.set(vel.x + dVel.x, vel.y + dVel.y);
  }
  
  
  PVector getAcc() {
    return acc.copy();
  }
  
 
  void setAcc(PVector newAcc) {
    acc.set(newAcc.x, newAcc.y);
  }
  
  
  void display() {
    pushMatrix();
    translate(pos.x, pos.y);
    rotate(angle);
    image(sprite, imageOffset.x, imageOffset.y);
    popMatrix();
  }
  
  
  void displayBoxes() {
    for (Hitbox h : boxes) {
      h.drawBox();
    }
  }
 
 
  PVector getCOM() {
    return COM.copy();
  }
  
  
  float getAngle() {
    return angle;
  }
  
  
  void adjustAngle(float dtheta) {
    angle += dtheta;
    for (Hitbox h : boxes) {
      h.adjustAngle(dtheta);
    }
  }
  
  
  float getAVel() {
    return aVel;
  }
  
  
  void setAVel(float newAVel) {
    aVel = newAVel;
  }
  
  
  void adjustAVel(float dAVel) {
    float newAVel = aVel + dAVel;
    setAVel(newAVel);
  }
  
  
  float getAngularAcc() {
    return aAcc;
  }
  
  
  void setAngularAcc(float newAngularAcc) {
    aAcc = newAngularAcc;
  }
  
  
  void adjustAngularAcc(float dAngularAcc) {
    float newAngularAcc = aAcc + dAngularAcc;
    setAngularAcc(newAngularAcc);
  }
  
  
  void setMass(float mass) {
    this.mass = mass;
    if (mass == -1) {
      // Mass = -1 signifies infinite mass
      invMass = 0;
      moment = -1;
      invMoment = 0;
      immovable = true; 
    }
    else {
      invMass = 1/mass;
      immovable = false;
    }
  }
  
  void setMoment(float moment) {
    this.moment = moment;
    if (moment == -1) {
      // Moment = -1 signifies infinite moment
      invMass = 0;
      mass = -1;
      invMoment = 0;
      immovable = true; 
    }
    else {
      invMoment = 1/moment;
      immovable = false;
    }
  }
  
  
  float mass() {
    return mass;
  }
  
  
  float moment() {
    return moment;
  }
  
  
  float invMass() {
    return invMass;
  }
  
  
  float invMoment() {
    return invMoment;
  }
  
  
  void setE(float newE) {
    elasticity = newE;
  }
  
  
  float getE() {
    return elasticity;
  }
  
  
  void setMu(float newMu) {
    muS = newMu;
    muK = 0.6*muS;
  }
  
  
  float getMuS() {
    return muS;
  }
  
  
  float getMuK() {
    return muK;
  }
  
  
  float getCharge() {
    return charge;
  }
  
  
  void setCharge(float newQ) {
    charge = newQ;
  }
  
  
  void setEngine(PVector newF) {
    engineForce = new PVector(newF.x, newF.y);
  }
  
  
  PVector getEngine() {
    return engineForce.copy();
  }
  
  
  void setID(String type, String name) {
    this.type = type;
    this.name = name;
  }
}