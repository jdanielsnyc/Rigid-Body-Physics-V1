World world;
Hitbox topBorder, bottomBorder, leftBorder, rightBorder;
Object top, bottom, left, right;
PImage tire, melon, orange, grapefruit, coconut, crate, rocket, boat, pin, die1, die2, die3, die4, die5, die6, background;


// FOR MENUS:
PFont mainTitle, subTitle, text1, text2, bigFont;
PImage massSymbol, bounceSymbol, frictionSymbol, gravIcon, elecIcon, magIcon, tireIcon, fruitIcon, diceIcon, crateIcon, pinIcon, rocketIcon, boatIcon, melonIcon, orangeIcon, grapefruitIcon, coconutIcon;
boolean inMenu, overMenu, itemMenu = false, statMenu = false, presetMenu = false, typeMode = false, hasTyped = false; // inMenu: a temporary editing window is open; overMenu: mouse is hovering over a menu window
boolean  mouseClicked, mouseReleased, enterPressed;
boolean gamePreset = false, rocketPreset = false;
int placeCode = 0; // a number corresponding to the current object/field held by the user
String numberInput = "", oldInput = "";
int inspectedObject = 0, fieldType = 0, fieldShape = 0;
PShape fieldArrow, cross;
float winOpacity = 0;

boolean skeletonMode = true;
boolean screenshotMode = false;

// TOTAL LINE COUNT: 3862 LINES OF CODE (NEAT!)

void setup() {
  background(225);
  size(1280, 700);
  world = new World();
  world.buildWalls();
  inititalizeIcons();
  
  // FOR MENUS:
  mainTitle = loadFont("AvenirNext-Bold-40.vlw");
  subTitle = loadFont("AvenirNext-Bold-20.vlw");
  text1 = loadFont("AvenirNext-Medium-16.vlw");
  text2 = loadFont("AvenirNext-DemiBold-16.vlw");
  bigFont = loadFont("AvenirNext-Heavy-160.vlw");
  
  massSymbol = loadImage("Mass.png");
  massSymbol.resize(25, 25);
  bounceSymbol = loadImage("Bounce.png");
  bounceSymbol.resize(45, 45);
  frictionSymbol = loadImage("Friction.png");
  frictionSymbol.resize(25, 25);
  background = loadImage("Mountain.jpg");
  background.resize(int(1580*1.325), int(700*1.264));
  inMenu = false; overMenu = false;
  mouseClicked = false; mouseReleased = false; enterPressed = false;
  
  float FAsize = 16;
  fieldArrow = createShape();
  fieldArrow.beginShape();
  fieldArrow.noStroke();
  fieldArrow.vertex(0, 0);
  fieldArrow.vertex(2.85, 2.85);
  fieldArrow.vertex(2.85, 3.85);
  fieldArrow.vertex(0, 1);
  fieldArrow.vertex(-2.85, 3.85);
  fieldArrow.vertex(-2.85, 2.85);
  fieldArrow.scale(FAsize);
  fieldArrow.endShape(CLOSE);
  
  float crossSize = 30;
  cross = createShape();
  cross.beginShape();
  cross.noStroke();
  cross.vertex(-2, -1);
  cross.vertex(-1, -2);
  cross.vertex(0, -1);
  cross.vertex(1, -2);
  cross.vertex(2, -1);
  cross.vertex(1, 0);
  cross.vertex(2, 1);
  cross.vertex(1, 2);
  cross.vertex(0, 1);
  cross.vertex(-1, 2);
  cross.vertex(-2, 1);
  cross.vertex(-1, 0);
  cross.endShape(CLOSE);
  cross.scale(crossSize);
  
  // frameRate(30);
}

void draw() {
  
  //println(gamePreset);
  
  // TO DO:
  // MINI-GAME, 3 LEVELS
  // SAT DEMONSTRATION
  // ROCKET CONTROL
  
  background(225);
  if (!skeletonMode) {
    image(background, -200, 0);
  }
  else {
    fill(70);
    rect(0, 680, 1280, 20);
  }
  world.run();
  if (gamePreset) {
    runGame();
  }
  else if (rocketPreset) {
    runRocket();
  }
  else {
    runMenus();
  }

  fill(120);
  textFont(subTitle);
  text(frameRate, 8, 670);
  
  if (!overMenu && !typeMode) {
    displayFieldGuide();
  }
  
  textFont(bigFont);
  fill(150, winOpacity);
  text("WINNER!", 200, 400);
  if (winOpacity > 0) {
    winOpacity-=5;
  }
  else winOpacity = 0;
  
  mouseReleased = false; enterPressed = false; // MUST REMAIN AT BOTTOM OF DRAW() AT ALL TIMES
}


void mouseReleased() {
  mouseReleased = true;
 
  if (!overMenu && !typeMode && !gamePreset && !rocketPreset) {
    if (placeCode < 7) {
      Object newObj;
      if (placeCode == 0) {
        newObj = buildObject("tire");
        newObj.setMass(100);
        newObj.setMoment(200000);
        newObj.setE(0.3);
        newObj.setMu(3);
      }
      else if (placeCode == 1) {
        newObj = buildObject("fruit");
        newObj.setMass(50);
        newObj.setMoment(80000);
        newObj.setE(0.55);
        newObj.setMu(0.3);
      }
      else if (placeCode == 2) {
        newObj = buildObject("die");
        newObj.setMass(40);
        newObj.setMoment(60000);
        newObj.setE(0.3);
        newObj.setMu(0.3);
      }
      else if (placeCode == 3) {
        newObj = buildObject("crate");
        newObj.setMass(120);
        newObj.setMoment(300000);
        newObj.setE(0);
        newObj.setMu(0.5);
      }
      else if (placeCode == 4) {
        newObj = buildObject("pin");
        newObj.setMass(50);
        newObj.setMoment(80000);
        newObj.setE(0.25);
        newObj.setMu(0.2);
      }
      else if (placeCode == 5) {
        newObj = buildObject("rocket");
        newObj.setMass(250);
        newObj.setMoment(2000000);
        newObj.setE(0.15);
        newObj.setMu(0.7);
      }
      else {
        newObj = buildObject("boat");
        newObj.setMass(200);
        newObj.setMoment(1100000);
        newObj.setE(0.15);
        newObj.setMu(0.7);
      }
      newObj.setAcc(new PVector(0, 300));
      newObj.setPos(mouseX, mouseY);
      world.addObj(newObj);
    }
    else if (placeCode == 7) {
      String direction, shape;
      float fieldStrength = 30;
      if (fieldType == 0) {
        direction = "up";
      } 
      else if (fieldType == 1) {
        direction = "right";
      }
      else if (fieldType == 2) {
        direction = "down";
      }
      else if (fieldType == 3) {
        direction = "left";
      }
      else {
        direction = "point";
        fieldStrength = 20000;
      }
      
      if (fieldShape == 0) {
        shape = "V";
      }
      else shape = "H";
      Field newField = new Field(new PVector(mouseX, mouseY), fieldStrength, "G", direction, shape);
      newField.name("Gravity Field");
      world.addField(newField);
    }
    else if (placeCode == 8) {
      String direction, shape;
      float fieldStrength = 30;
      if (fieldType == 0) {
        direction = "up";
      } 
      else if (fieldType == 1) {
        direction = "right";
      }
      else if (fieldType == 2) {
        direction = "down";
      }
      else if (fieldType == 3) {
        direction = "left";
      }
      else {
        direction = "point";
        fieldStrength = 0.00000003;
      }
      
      if (fieldShape == 0) {
        shape = "V";
      }
      else shape = "H";
      Field newField = new Field(new PVector(mouseX, mouseY), fieldStrength, "E", direction, shape);
      newField.name("Electric Field");
      world.addField(newField);
    }
    else if (placeCode == 9) {
      String direction;
      if (fieldType == 0) {
        direction = "in";
      }
      else direction = "out";
      Field newField = new Field(new PVector(mouseX, mouseY), 2, "M", direction, "H");
      newField.name("Magic Field");
      world.addField(newField);
    }
  }
}


void vector(float x, float y, PVector vector) {
  // Draws a vector at a point
  line(x, y, x + vector.x, y + vector.y);
}


PVector[] copyArray(PVector[] original) {
  PVector[] returnArray = new PVector[original.length];
  for (int i = 0; i < original.length; i++) {
    returnArray[i] = original[i].copy();
  }
  return returnArray;
}


void displayFieldGuide() {
  if (placeCode == 7) {
    fill(133, 100, 216, 100);
    if (fieldType == 4) {
      ellipse(mouseX - 20, mouseY + 5, 30, 30);
      ellipse(mouseX - 20, mouseY + 5, 26, 26);
    }
    else {
      if (fieldShape == 0) {
          rect(mouseX - 20, mouseY - 10, 15, 30);
          rect(mouseX - 18, mouseY - 8, 11, 26);
      }
      else {
        rect(mouseX - 35, mouseY - 10, 30, 15);
        rect(mouseX - 33, mouseY - 8, 26, 11);
      }
    }
    String direction;
    if (fieldType == 0) {
      direction = "up";
    } 
    else if (fieldType == 1) {
      direction = "right";
    }
    else if (fieldType == 2) {
      direction = "down";
    }
    else if (fieldType == 3) {
      direction = "left";
    }
    else {
      direction = "point";
    }
    fill(50);
    text(direction, mouseX + 5, mouseY);
  }
  else if (placeCode == 8) {
    fill(74, 132, 210, 100);
    if (fieldType == 4) {
      ellipse(mouseX - 20, mouseY + 5, 30, 30);
      ellipse(mouseX - 20, mouseY + 5, 26, 26);
    }
    else {
      if (fieldShape == 0) {
          rect(mouseX - 20, mouseY - 10, 15, 30);
          rect(mouseX - 18, mouseY - 8, 11, 26);
      }
      else {
        rect(mouseX - 35, mouseY - 10, 30, 15);
        rect(mouseX - 33, mouseY - 8, 26, 11);
      }
    }
    String direction;
    if (fieldType == 0) {
      direction = "up";
    } 
    else if (fieldType == 1) {
      direction = "right";
    }
    else if (fieldType == 2) {
      direction = "down";
    }
    else if (fieldType == 3) {
      direction = "left";
    }
    else {
      direction = "point";
    }
    fill(50);
    text(direction, mouseX + 5, mouseY);
  }
  else if (placeCode == 9) {
    fill(195, 0, 0, 100);
    rect(mouseX - 25, mouseY - 10, 20, 20);
    rect(mouseX - 23, mouseY - 8, 16, 16);
    String direction;
    if (fieldType == 0) {
      direction = "in";
    }
    else {
      direction = "out";
    }
    fill(50);
    text(direction, mouseX + 5, mouseY);
  }
}
