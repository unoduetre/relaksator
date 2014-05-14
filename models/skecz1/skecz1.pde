import processing.opengl.*;
import saito.objloader.*;

OBJModel model ;
float rotX, rotY;

void setup()
{
    size(480, 800,P3D);//P3D,OPENGL
    smooth();
    orientation(PORTRAIT);
    model = new OBJModel(this, "HAND.obj", "absolute", TRIANGLES);
    //model.enableDebug();
    model.scale(30);
    model.translateToCenter();
    stroke(255);
    noStroke();
}


void draw()
{
    background(129);
    lights();
    pushMatrix();
    translate(width/2, height/2, 0);
    rotateX(rotY);
    rotateY(rotX);
    model.draw();
    popMatrix();
    println(frameRate);
    //opengl: 30-42 fps
    //p3d: podobnie ale kilka fps lepiej
}

boolean bTexture = true;
boolean bStroke = false;

void mouseDragged()
{
    rotX += (mouseX - pmouseX) * 0.01;
    rotY -= (mouseY - pmouseY) * 0.01;
}

