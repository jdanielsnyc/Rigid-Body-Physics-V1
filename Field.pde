class Field {
  
  PVector pos;
  float power; // charge of point charge in C for point electric fields, N/C for directed electric fields, m/s^2 for gravitational fields, T for magnetic fields
  String type, direction, shape, name;
  float timer;
  float SIconv = 30, w, h; // 1 meter = 30 pixels
  Hitbox box;
  
  Field(PVector pos, float power, String type, String direction, String shape) {
    this.pos = pos.copy();
    this.power = power;
    this.type = type;
    this.direction = direction;
    this.shape = shape;
    if (direction != "point") {
      if (type == "M") {
        w = 300;
        h = 300;
      }
      else if (shape == "H") {
        w = 450;
        h = 150;
      }
      else if (shape == "V") {
        w = 150;
        h = 450;
      }
      PVector[] verts = {
        new PVector(pos.x - w/2, pos.y - h/2), 
        new PVector(pos.x + w/2, pos.y - h/2), 
        new PVector(pos.x + w/2, pos.y + h/2), 
        new PVector(pos.x - w/2, pos.y + h/2)
      };
      box = new Hitbox(verts);
      box.setPos(pos.x, pos.y);
    }
    
    timer = 0;
  }
  
  
  PVector getForce(Object obj) {
    PVector force = new PVector(0, 0);
    // IN WORLD, CHECK IF OBJ IS IN FIELD IF THE FIELD ISN'T A POINT CHARGE
    float m = obj.mass();
    if (m == -1) {
      return force.copy();
    }
    PVector rV = obj.getCOM().copy().sub(pos); // radius vector
    float r = rV.mag() / SIconv; // in meters
    float q = obj.getCharge(); // in coulombs
    PVector v = obj.getVel().div(SIconv);
    
    if (type == "E") {
      if (direction == "point") {
        float forceMag = (8.999 * pow(10, 9) * power * q) / pow(r + 0.001, 2);
        if (abs(forceMag) > 10 * m || r == 0) {
          //force = rV.copy().normalize().mult(10 * m * q/abs(q) * power/abs(power));
        }
        force = rV.copy().normalize().mult(forceMag);
      }
      else if (direction == "up") {
        force = new PVector(0, -1 * power * q);
      }
      else if (direction == "down") {
        force = new PVector(0, power * q);
      }
      else if (direction == "left") {
        force = new PVector(-1 * power * q, 0);
      }
      else if (direction == "right") {
        force = new PVector(power * q, 0);
      }
      println(force);
    }
    else if (type == "G") {
      if (direction == "point") {
        float forceMag = (power * m) / pow(r + 0.001, 2);
        println(m);
        if (abs(forceMag) > 50 * m || r == 0) {
          force = rV.copy().normalize().mult(-50 * m);
        }
        else force = rV.copy().normalize().mult(-forceMag);
      }
      else if (direction == "up") {
        force = new PVector(0, -1 * power * m);
      }
      else if (direction == "down") {
        force = new PVector(0, power * m);
      }
      else if (direction == "left") {
        force = new PVector(-1 * power * m, 0);
      }
      else if (direction == "right") {
        force = new PVector(power * m, 0);
      }
    }
    else if (type == "M") {
      if (direction == "in") {
        force = v.copy().cross(new PVector(0, 0, power)).mult(q);
      }
      else if (direction == "out") {
        force = v.copy().cross(new PVector(0, 0, -power)).mult(q);
      }
    }
    return force.copy();
  }
  
  
  Hitbox getBox() {
    return box;
  }
  
  
  boolean isPoint() {
    return direction == "point";
  }
  
  
  void display() {
    timer += 0.2 * 60/frameRate;
    color c;
    noStroke();
    
    if (type == "E") {
      c = color(74, 132, 210);
    }
    else if (type == "G") {
      c = color(133, 100, 216);
    }
    else c = color(195, 0, 0);
    
    if (direction != "point") {
      if (type != "M") {
        float delay = PI/6;
        float mag = 90;
        float rotation = 0;
        
        if (direction == "right") {
          rotation = PI/2;
        }
        else if (direction == "down") {
          rotation = PI;
        }
        else if (direction == "left") {
          rotation = -PI/2;
        }
        
        pushMatrix();
        translate(pos.x, pos.y);
        rotate(rotation);
        if (sin(PI*timer/10) > 0) {
          float mult = mag*sin(PI*timer/10);
          fieldArrow.setFill(colorAdd(c, mult)); 
        }
        else fieldArrow.setFill(c); 
        shape(fieldArrow, 0, - 78.5 * 0.8);
        
        if (sin(PI*timer/10 + delay) > 0) {
          float mult = mag*sin(PI*timer/10 + delay);
          fieldArrow.setFill(colorAdd(c, mult - 50)); 
        }
        else fieldArrow.setFill(colorAdd(c, -50)); 
        shape(fieldArrow, 0, - 58.5 * 0.8);
        
        if (sin(PI*timer/10 + 2*delay) > 0) {
          float mult = mag*sin(PI*timer/10 + 2*delay);
          fieldArrow.setFill(colorAdd(c, mult)); 
        }
        else fieldArrow.setFill(c); 
        shape(fieldArrow, 0, - 18.5 * 0.8);
        
        if (sin(PI*timer/10 + 3*delay) > 0) {
          float mult = mag*sin(PI*timer/10 + 3*delay);
          fieldArrow.setFill(colorAdd(c, mult - 50)); 
        }
        else fieldArrow.setFill(colorAdd(c, -50)); 
        shape(fieldArrow, 0, 1.5 * 0.8);
        popMatrix();
      }
      else {
        float mult = 60*sin(PI*timer/15);
        color hue;
        if (direction == "in") {
          if (mult > 0) {
            hue = colorAdd(c, mult);
          }
          else hue = c;
          cross.setFill(colorAdd(hue, -70));
          shape(cross, pos.x + 1, pos.y + 3.5);
          cross.setFill(hue);
          shape(cross, pos.x - 1, pos.y - 3.5);
        }
        else {
          if (mult > 0) {
            hue = colorAdd(c, mult);
          }
          else hue = c;
          fill(colorAdd(hue, -90));
          ellipse(pos.x + 1.5, pos.y + 1.5, 50, 50);
          fill(hue);
          ellipse(pos.x - 1.5, pos.y - 1.5, 50, 50);
        }
      }
      fill(c, 50);
      rect(pos.x - w/2, pos.y - h/2, w, h);
      rect(pos.x - w/2 + 5, pos.y - h/2 + 5, w - 10, h - 10);
    }
    else {
      if (type == "G") {
        float maxSize = 500;
        float animationLength = 50;
        int pulseCount = 5;
        int maxOpacity = 150;
        for (int i = 0; i < pulseCount; i++) {
          float currentSize = maxSize - (maxSize * ((timer + i * animationLength/pulseCount) % animationLength) / animationLength);
          float o = maxOpacity * pow((1 - currentSize / maxSize), 2);
          fill(c, o);
          ellipse(pos.x, pos.y, currentSize, currentSize);
        }
      }
      else {
        float maxSize = 500;
        float animationLength = 50;
        int pulseCount = 5;
        int maxOpacity = 150;
        for (int i = 0; i < pulseCount; i++) {
          float currentSize = maxSize * ((timer + i * animationLength/pulseCount) % animationLength) / animationLength;
          float o = maxOpacity * pow((1 - currentSize / maxSize), 2);
          fill(c, o);
          ellipse(pos.x, pos.y, currentSize, currentSize);
        }
      }
    }

  }
  
  
  color colorAdd(color c, float add) {
    return color(red(c) + add, green(c) + add, blue(c) + add);
  }
  
  
  void name(String name) {
    this.name = name;
  }
}