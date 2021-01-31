Object buildObject(String type) {
  
  PVector[] nullP = {new PVector(0, 0)};
  Hitbox[] nullBox = {new Hitbox(nullP)};
  PVector[] nullOffsets = {new PVector(0, 0)};
  Object returnObj = new Object(nullBox, nullOffsets); // IDE declares an error if returnObj isn't initialized
  
  if (type == "tire" || type == "fruit") {
    float size;
    if (type == "tire") {
      size = 50;
    }
    else {
      size = 35;
    }
    Hitbox sphere = new Hitbox(new PVector(0, 0), size);
    Hitbox[] boxArray = {sphere};
    
    float xShift = 0;
    float yShift = 0;
    PVector[] offsets = {
      new PVector(xShift, yShift)
    };

    returnObj = new Object(boxArray, offsets);
    
    if (type == "tire") {
      returnObj.initializeSprite(tire, new PVector(-50, -50));
      returnObj.setID(type, "Car Circle");
    }
    else {
      int fruitNo = int(random(3.999999));
      if (fruitNo == 0) {
        returnObj.initializeSprite(melon, new PVector(-35, -35));
        returnObj.setID(type, "Melon");
      }
      else if (fruitNo == 1) {
        returnObj.initializeSprite(orange, new PVector(-35, -40.5));
        returnObj.setID(type, "Orange");
      }
      else if (fruitNo == 2) {
        returnObj.initializeSprite(grapefruit, new PVector(-35, -35));
        returnObj.setID(type, "Grapefruit");
      }
      else {
        returnObj.initializeSprite(coconut, new PVector(-35, -35));
        returnObj.setID(type, "Coconut");
      }
    }
  }
  else if (type == "crate") {
    float size = 50;
    float mult = sqrt(2*size*size);
    PVector[] square = {
      new PVector(mult*cos(PI/4), mult*sin(PI/4)),
      new PVector(mult*cos(3*PI/4), mult*sin(3*PI/4)),
      new PVector(mult*cos(5*PI/4), mult*sin(5*PI/4)),
      new PVector(mult*cos(7*PI/4), mult*sin(7*PI/4)),
    };
    
    Hitbox[] boxArray = {
      new Hitbox(square)
    };
    
    float xShift = 0;
    float yShift = 0;
    PVector[] offsets = {
      new PVector(xShift, yShift)
    };

    returnObj = new Object(boxArray, offsets);
    
    returnObj.initializeSprite(crate, new PVector(-50, -50));
    returnObj.setID(type, "Suspicious Box");
  }
  else if (type == "die") {
    float size = 28;
    float mult = sqrt(2*size*size);
    PVector[] die = {
      new PVector(22 * size/25, 16 * size/25),
      new PVector(20 * size/25, 20 * size/25),
      new PVector(16 * size/25, 22 * size/25),
      
      new PVector(-16 * size/25, 22 * size/25),
      new PVector(-20 * size/25, 20 * size/25),
      new PVector(-22 * size/25, 16 * size/25),
      
      new PVector(-22 * size/25, -16 * size/25),
      new PVector(-20 * size/25, -20 * size/25),
      new PVector(-16 * size/25, -22 * size/25),
      
      new PVector(16 * size/25, -22 * size/25),
      new PVector(20 * size/25, -20 * size/25),
      new PVector(22 * size/25, -16 * size/25)
    };
    
    Hitbox[] boxArray = {
      new Hitbox(die)
    };
    
    float xShift = 0;
    float yShift = 0;
    PVector[] offsets = {
      new PVector(xShift, yShift)
    };

    returnObj = new Object(boxArray, offsets);

    int dieNo = int(random(5.999999));
    if (dieNo == 0) {
      returnObj.initializeSprite(die1, new PVector(-25, -25));
      returnObj.setID(type, "1 Die");
    }
    else if (dieNo == 1) {
      returnObj.initializeSprite(die2, new PVector(-25, -25));
      returnObj.setID(type, "2 Die");
    }
    else if (dieNo == 2) {
      returnObj.initializeSprite(die3, new PVector(-25, -25));
      returnObj.setID(type, "3 Die");
    }
    else if (dieNo == 3) {
      returnObj.initializeSprite(die4, new PVector(-25, -25));
      returnObj.setID(type, "4 Die");
    }
    else if (dieNo == 4) {
      returnObj.initializeSprite(die5, new PVector(-25, -25));
      returnObj.setID(type, "5 Die");
    }
    else {
      returnObj.initializeSprite(die6, new PVector(-25, -25));
      returnObj.setID(type, "6 Die");
    }
  
  }
  else if (type == "complexTest") {
    PVector[] body = {
      new PVector(50*cos(0), 50*sin(0)),
      new PVector(50*cos(2*PI/4), 50*sin(2*PI/4)),
      new PVector(50*cos(4*PI/4), 50*sin(4*PI/4)),
      new PVector(2*50*cos(6*PI/4), 2*50*sin(6*PI/4)),
    };
    
    PVector[] rightWing = {
      new PVector(270/3, -50/3),
      new PVector(80/3, 170/3),
      new PVector(-130/3, 150/3),
      new PVector(-230/3, -50/3),
      new PVector(70/3, -150/3)
    };
    
    PVector[] leftWing = {
      new PVector(-70/3, -150/3),
      new PVector(230/3, -50/3),
      new PVector(130/3, 150/3),
      new PVector(-80/3, 170/3),
      new PVector(-270/3, -50/3)
    };

    Hitbox[] boxArray = {
      new Hitbox(body), 
      new Hitbox(leftWing), 
      new Hitbox(rightWing)
    };
    
    float xShift = 0;
    float yShift = 0;
    PVector[] offsets = {
      new PVector(xShift, yShift), 
      new PVector(xShift - 80, yShift - 67), 
      new PVector(xShift + 80, yShift - 67)
    };
    
    returnObj = new Object(boxArray, offsets);
  }
  else if (type == "pin") {
    PVector[] belly = {
      new PVector(-11, -43),
      new PVector(11, -43),
      new PVector(21, -17),
      new PVector(25, 4),
      new PVector(22, 24),
      new PVector(10, 51),
      new PVector(-10, 51),
      new PVector(-22, 24),
      new PVector(-25, 4), 
      new PVector(-21, -17)
    };
    
    PVector[] neck = {
      new PVector(-10, -69),
      new PVector(10, -69),
      new PVector(11, -43),
      new PVector(-11, -43),
    };
    
    PVector[] head = {
      new PVector(-10, -69),
      new PVector(-13, -88),
      new PVector(-10, -96),
      new PVector(-4, -100),
      new PVector(4, -100),
      new PVector(10, -96),
      new PVector(13, -88),
      new PVector(10, -69)
    };

    Hitbox[] boxArray = {
      new Hitbox(belly),
      new Hitbox(neck),
      new Hitbox(head)
    };
    
    PVector[] offsets = {
      new PVector(0, 3.8),
      new PVector(0, -56),
      new PVector(0, -88.25)
    };
    
    returnObj = new Object(boxArray, offsets);
    
    returnObj.initializeSprite(pin, new PVector(-25, -100));
    returnObj.setID(type, "Bowling Pin");
  }
  else if (type == "rocket") {
    PVector[] body = {
      new PVector(0, -160), // tip
      
      // right side
      new PVector(9, -155),
      new PVector(21, -142),
      new PVector(37, -112),
      new PVector(47, -78),
      new PVector(51, -24),
      new PVector(49, 16),
      new PVector(31, 64),
      new PVector(25, 71),
      
      // left side
      new PVector(-22, 71),
      new PVector(-28, 64),
      new PVector(-46, 16),
      new PVector(-49, -24),
      new PVector(-46, -70),
      new PVector(-33, -112),
      new PVector(-17, -142),
      new PVector(-8, -155)
    };
    
    PVector[] leftWing = {
      new PVector(-49, -26),
      new PVector(0, -31),
      new PVector(0, 22),
      new PVector(-35, 48),
      new PVector(-73, 76),
      new PVector(-73, 41),
      new PVector(-67.5, -1),
      new PVector(-62, -14)
    };
    
    PVector[] rightWing = {
      new PVector(51, -26),
      new PVector(61, -18),
      new PVector(69, -2),
      new PVector(74, 35),
      new PVector(73, 75),
      new PVector(38, 48),
      new PVector(0, 22),
      new PVector(0, -31)
    };

    Hitbox[] boxArray = {
      new Hitbox(body),
      new Hitbox(leftWing),
      new Hitbox(rightWing)
    };
    
    PVector[] offsets = {
      new PVector(1.2352941, -51.294117),
      new PVector(-44.9375, 14.375),
      new PVector(45.75, 12.87)
    };
    
    returnObj = new Object(boxArray, offsets);
    
    returnObj.initializeSprite(rocket, new PVector(-75, -160));
    returnObj.setID(type, "Not-A-Missle™");
  }
  else if (type == "boat") {
    PVector[] hull = {
      new PVector(-75, -4),
      new PVector(125, -36),
      new PVector(84, 18),
      new PVector(-72, 18)
    };
    
    PVector[] sail = {
      new PVector(0, -163.5),
      new PVector(88, -30),
      new PVector(-65.5, -5.5)
    };
    
    PVector[] mast = {
      new PVector(-1, -190),
      new PVector(3, -190),
      new PVector(3, 0),
      new PVector(-1, 0)
    };

    Hitbox[] boxArray = {
      new Hitbox(hull),
      new Hitbox(sail),
      new Hitbox(mast)
    };
    
    PVector[] offsets = {
      new PVector(15.5, -1.0),
      new PVector(7.5, -66.333336),
      new PVector(1, -95.0)
    };
    
    returnObj = new Object(boxArray, offsets);
    
    returnObj.initializeSprite(boat, new PVector(-75, -190));
    returnObj.setID(type, "Titanic II");
  }
  
  return returnObj;
}



void inititalizeIcons() {
  tire = loadImage("Tire.png");
  tire.resize(100, 100); 
  // orange is resize(100, 115), offset(-50, -57.5);
  // rocket is resize(100, 158), offset(-50, -79);
  // bowling pin is resize(50, 152)
  melon = loadImage("Melon.png");
  melon.resize(70, 70); 
  orange = loadImage("Orange.png");
  orange.resize(70, 81); 
  grapefruit = loadImage("Grapefruit.png");
  grapefruit.resize(70, 70); 
  coconut = loadImage("Coconut.png");
  coconut.resize(70, 70); 
  
  crate = loadImage("Crate.png");
  crate.resize(100, 100);
  rocket = loadImage("Rocket.png");
  rocket.resize(150, 237);
  boat = loadImage("Boat.png");
  boat.resize(200, 209);
  pin = loadImage("BowlingPin.png");
  pin.resize(50, 152);
  
  die1 = loadImage("1die.png");
  die1.resize(50, 50);
  die2 = loadImage("2die.png");
  die2.resize(50, 50);
  die3 = loadImage("3die.png");
  die3.resize(50, 50);
  die4 = loadImage("4die.png");
  die4.resize(50, 50);
  die5 = loadImage("5die.png");
  die5.resize(50, 50);
  die6 = loadImage("6die.png");
  die6.resize(50, 50);
  
  tireIcon = loadImage("Tire.png");
  tireIcon.resize(80, 80);
  fruitIcon = loadImage("Fruits.png");
  fruitIcon.resize(65, 65);
  diceIcon = loadImage("DiceIcon.png");
  diceIcon.resize(108, 70);
  crateIcon = loadImage("Crate.png");
  crateIcon.resize(70, 70);
  pinIcon = loadImage("PinIcon.png");
  pinIcon.resize(72, 80);
  rocketIcon = loadImage("RocketIcon.png");
  rocketIcon.resize(110, 59);
  boatIcon = loadImage("Boat.png");
  boatIcon.resize(72, 75);
  gravIcon = loadImage("BlackHole.png");
  gravIcon.resize(80, 80);
  elecIcon = loadImage("ElectricIcon.png");
  elecIcon.resize(70, 70);
  magIcon = loadImage("MagnetSymbol.png");
  magIcon.resize(56, 75);
  
  melonIcon = loadImage("Melon.png");
  melonIcon.resize(65, 65);
  orangeIcon = loadImage("Orange.png");
  orangeIcon.resize(65, 75);
  grapefruitIcon = loadImage("Grapefruit.png");
  grapefruitIcon.resize(65, 65);
  coconutIcon = loadImage("Coconut.png");
  coconutIcon.resize(65, 65);
  
  // ITEMS: Tire, fruit, crate, rocket, boat, bowling pin, dice
}