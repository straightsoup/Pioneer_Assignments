class Ball {

  float radius = 15;
  Body body;//the body representing the ball in the box2d world
  boolean isWhite = false;
  boolean stopped = true; //has the ball stopped or is it still moving
  Box2DProcessing world;
  boolean sunk = false;//whether the ball is sunk or not
  color ballColor; //ballColor of the ball
  int point;
  boolean display = true;
  
  color redBall = color(180, 0, 0);
  color yellowBall = color(231, 195, 27);
  color greenBall = color(14, 125, 63);
  color brownBall = color(110, 64, 25);
  color blueBall = color(19, 44, 170);
  color pinkBall = color(255, 192, 203);
  color blackBall = color(0);

  //------------------------------------------------------------------------------------------------------------------------------------------------------------------
  //constructor
  Ball(float x, float y, Box2DProcessing box2d, int point) {
    
    switch (point) {
      case 1: 
        this.ballColor = color(redBall); 
        break;
      case 2: 
        this.ballColor = color(yellowBall);
        break;
      case 3: 
        this.ballColor = color(greenBall);
        break;
      case 4: 
        this.ballColor = color(brownBall);
        break;
      case 5: 
        this.ballColor = color(blueBall);
        break;
      case 6: 
        this.ballColor = color(pinkBall);
        break;
      case 7: 
        this.ballColor = color(blackBall);
        break;
      default:
        this.ballColor = color(220);
        this.isWhite = true;
        break;
      }
      
    world = box2d;
    Vec2 pos = new Vec2(x, y);


    float r = world.scalarPixelsToWorld(radius); //convert the radius to world coordinates

    //CREATE BODY DEFINITION
    BodyDef df = new BodyDef();
    df.type = BodyType.DYNAMIC;
    df.position.set(world.coordPixelsToWorld(pos.x, pos.y));

    //APPPLY IT TO THE BODY
    body = world.createBody(df);


    //CREATE SHAPE AS CIRCLE
    CircleShape circle = new CircleShape();
    circle.setRadius(r);

    //CREATE FIXTURE
    FixtureDef fd = new FixtureDef();
    fd.shape = circle;
    fd.density = 0.0000001;//very low density
    fd.friction = 0.001;//low friction
    fd.restitution = 0.9;//high bounciness

    //FIX THE SHAPE TO THE BODY;
    body.createFixture(fd);
  }
  //------------------------------------------------------------------------------------------------------------------------------------------------------------------
  void applyFriction() {//called every step to simulate friction between the table and ball
    Vec2 vel = body.getLinearVelocity(); 
    vel.mulLocal(0.985);//slow by 2%
    if (vel.length() < 4) {//increase friction when slower
      vel.mulLocal(0.95);
    }
    if (vel.length() < 1) {//stop the ball if the speed is slow enough because without this the speed will never reach 0
      vel.mulLocal(0);
    }
  }

  //------------------------------------------------------------------------------------------------------------------------------------------------------------------
  //whether the ball is in a hole or not
  boolean isInHole() {
    if (sunk) {//if ball is already sunk then problem solved
      return true;
    }
    Vec2 pos = world.getBodyPixelCoord(body);//get the position and if its within 15 of a holes center then it is sunk
    for (int i = 0; i < 6; i++) {
      if (dist(pos.x, pos.y, tables[0].holes[i].pos.x, tables[0].holes[i].pos.y) < 20) {
        Vec2 vel = body.getLinearVelocity(); 
        vel.mulLocal(0);//set speed to 0
        sunk = true;
        world.destroyBody(body);//remove ball from world
        return true;
      }
    }
    return false;
  }

  //------------------------------------------------------------------------------------------------------------------------------------------------------------------
  boolean isStopped() {//is the ball stopped

    if (body.getLinearVelocity().length() == 0) {
      return true;
    } else {
      return false;
    }
  }
  //------------------------------------------------------------------------------------------------------------------------------------------------------------------
  void update() {//update ball (kind of useless but I though I would do more than just apply friction each update)
    applyFriction();
  }
  //------------------------------------------------------------------------------------------------------------------------------------------------------------------
  //draw a circle representing the ball
  void show() {
    if (!sunk && display) {//if sunk then dont bother showing it
    
      Vec2 pos = world.getBodyPixelCoord(body); //get position

      pushMatrix();
      translate(pos.x, pos.y);
      if (isWhite) {//choose ballColor
        fill(220);
      } else {
        fill(ballColor);
      }
      ellipse(0, 0, 2*radius, 2*radius);//draw ball
      noStroke();
      fill(255, 180);
      //ellipse(radius*0.1, -radius*0.4, radius*0.5, radius*0.5);
      stroke(0);
      popMatrix();
    }
  }
  //------------------------------------------------------------------------------------------------------------------------------------------------------------------
  //simulates a shot
  void applyForce(Vec2 force) {
    Vec2 scaledForce = new Vec2(force.x, force.y);
    scaledForce.mulLocal(random(5000000, 50000000));
    body.applyForce(scaledForce, body.getWorldCenter());//apply force on ball
  }

  //---------------------------------------------------------------------------------------------------------------------------------------------------------------
  //creates and returns a clone of this ball object in the parameter world
  Ball clone(Box2DProcessing World) {

    Vec2 pos = World.getBodyPixelCoord(body); //get pixel coord
    Ball clone = new Ball(pos.x, pos.y, World, ballColor);

    clone.isWhite = isWhite;
    clone.sunk = sunk;
    if (sunk) {//if the ball is sunk then remove the body from the world
      World.destroyBody(clone.body);
    }
    return clone;
  }
}
