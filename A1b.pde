PImage[] texture_pool;
int POOL_SZ = 3;
ArrayList<Ball> balls;
int BALL_WIDTH = 30;
int BOX_WIDTH = 650;
int BOX_HEIGHT = 400;
int BOX_DEPTH = 300;
int MAX_SPEED = 15;
float SLOW_FACTOR = 0.95;
float STOP_FACTOR = 0.05;
float GRAVITY = 1.0;
float COLLISION_FACTOR = 1.5;

void setup() {
  size(640, 360, P3D);
  // initialise the textures
  texture_pool = new PImage[POOL_SZ];
  texture_pool[0] = loadImage("img/avatar.jpeg");
  texture_pool[1] = loadImage("img/earth.jpg");
  texture_pool[2] = loadImage("img/moon.jpg");
  // initialise the balls
  balls = new ArrayList<Ball>();
}

void draw() {
  background(0);
  translate(width/2, height/2, 0);
  stroke(255);
  noFill();
  
  // draw box
  box(BOX_WIDTH, BOX_HEIGHT, BOX_DEPTH);
  
  // draw balls
  for (int i = 0; i < balls.size(); i++) {
    Ball b = balls.get(i);
    b.show();
    b.update(i);
  }
    
}

// create new ball when user clicks mouse
void mouseClicked() {
 int texture_ind = int(random(POOL_SZ));
 PImage texture = texture_pool[texture_ind];
 Ball b_new = new Ball(mouseX - width/2, mouseY - height/2, texture);
 balls.add(b_new);
}

class Ball {
  // x, y, z positions
  float x = 0;
  float y = 0;
  float z = 0;
  // displacement for x, y, z positions
  float dx = random(-MAX_SPEED, MAX_SPEED);
  float dy = random(-MAX_SPEED, MAX_SPEED);
  float dz = random(-MAX_SPEED, MAX_SPEED);
  // boolean to check if ball is stationary
  int stationary = 0;
  // stores the shape of the ball
  PShape ball;
  
  Ball(float X, float Y, PImage texture) {
    x = X;
    y = Y;
    ball = createShape(SPHERE, BALL_WIDTH);
    ball.setTexture(texture);
    ball.setStroke(false);
  }
  
  void show() {
    pushMatrix();
    // set location of the ball
    translate(x, y, z);
    // spin the ball until it is stationary
    if (stationary == 0) {
      rotateY(frameCount / PI/8);
    }
    shape(ball);
    popMatrix();
  }
  
  // collision detection with the walls
  void wall_bounce(float x_prev, float y_prev, float z_prev) {
    // [1] Check if the ball is outside the boundary of each x,y,z dim
    // [2] Decay the energy of the ball
    // [3] Bounce off the wall in the opposite direction
    // [4] Check if the ball should be stationary on the bottom wall
    
    int x_bound = (BOX_WIDTH - BALL_WIDTH)/2;
    int y_bound = (BOX_HEIGHT - BALL_WIDTH)/2;
    int z_bound = (BOX_DEPTH - BALL_WIDTH)/2;
    
    // left and right walls
    if (x >= x_bound || x <= -x_bound) {
      dx *= -SLOW_FACTOR;
      x += dx;
    }
    
    // top and bottom walls
    if (y >= y_bound || y <= -y_bound) {
      dy *= -SLOW_FACTOR;
      y += dy;

      if (sqrt(sq(x_prev - x)) < STOP_FACTOR) {
        if (sqrt(sq(y_prev - y)) < STOP_FACTOR) {
          if (sqrt(sq(z_prev - z)) < STOP_FACTOR) {
            stationary = 1;
          }
        }
      }
    }
    
    // front and back walls
    if (z >= z_bound || z <= -z_bound) {
      dz *= -SLOW_FACTOR;
      z += dz;
    } 
  }
  
  // collision detection with other balls
  void ball_bounce(int i) {
    for (int j = i+1; j < balls.size(); j++) {
      Ball b_next = balls.get(j);
      
      if (sqrt(sq(b_next.x - x)) <= BALL_WIDTH) {
        if (sqrt(sq(b_next.y - y)) <= BALL_WIDTH) {
          if (sqrt(sq(b_next.z - z)) <= BALL_WIDTH) {
            // update displacements of the colliding balls
            dx *= -COLLISION_FACTOR;  
            dy *= -COLLISION_FACTOR;          
            dz *= -COLLISION_FACTOR;
            b_next.dx *= -COLLISION_FACTOR;
            b_next.dy *= -COLLISION_FACTOR;
            b_next.dz *= -COLLISION_FACTOR;
            
            // update positions of the colliding balls
            x += dx;
            y += dy;
            z += dz;
            b_next.x += b_next.dx;
            b_next.y += b_next.dy;
            b_next.z += b_next.dz;
            
            // ensure that the balls are not marked as stationary
            stationary = 0;
            b_next.stationary = 0;
          }
        }
      }
    }
  }
  
  void update(int i) {
    // [1] ball slows down by SLOW_FACTOR over time
    // [2] ball falls down due to gravity
    // [3] move the ball if it is not stationary
    
    float x_prev = x;
    float y_prev = y;
    float z_prev = z;
    
    dx *= SLOW_FACTOR;
    dy += GRAVITY;
    dy *= SLOW_FACTOR;
    dz *= SLOW_FACTOR;
    
    if (stationary == 0) {
      x += dx;
      y += dy;
      z += dz;
    }
    
    // check for collisions with the walls
    wall_bounce(x_prev, y_prev, z_prev);
    
    // check for collisions with other balls
    ball_bounce(i);
  }
}
