import ketai.camera.KetaiCamera;
import papaya.Mat;
import java.util.LinkedList;

public static class MatchingView extends View
{

  protected Integer cameraWidth = 640;
  protected Integer cameraHeight = 480;  
  protected KetaiCamera camera = null;
  protected PImage photo = null;
  protected Integer previewWidth = null;
  protected Integer previewHeight = null;
  protected PImage uvImage = null;
  protected float[][] matrix = null;
  protected Float left = null;
  protected Float right = null;
  protected Float top = null;
  protected Float bottom = null;
  protected Boolean dragging = true;
  protected ColladaTriangles triangles = null;
  protected List<Float> uv = null;
  protected PGraphics graphics = null;
  
  protected ColladaFloatArray floatArray = null; 
  
  protected Boolean takingPhoto = true;
  
  public MatchingView(PApplet pApplet, Collada collada) throws Exception
  {
    super(pApplet, collada);
    
    camera = new KetaiCamera(pApplet, cameraWidth, cameraHeight, 30);
    graphics = pApplet.createGraphics(cameraHeight, cameraWidth);
    
    Float ratio = null;
    
    if(pApplet.height/pApplet.width > cameraWidth/cameraHeight)
    {
      ratio = float(pApplet.height) / float(cameraWidth);
    }
    else
    {
      ratio = float(pApplet.width) / float(cameraHeight);
    }
    previewWidth = int(ratio * cameraHeight);
    previewHeight = int(ratio * cameraWidth);
    
    left = (pApplet.width - previewWidth) / 2.0;
    top = (pApplet.height - previewHeight) / 2.0;
    right = left + previewWidth;
    bottom = top + previewHeight;
    
    uvImage = pApplet.loadImage("uv.png");
    triangles = ((ColladaGeometry)collada.getById("glowka002-lib")).getMesh().getTriangles();
    floatArray = ((ColladaTechniqueCommonInSource)triangles.getTexcoordSource().getTechnique()).getAccessor().getSource(ColladaFloatArray.class);
  }
  
  public void show()
  {
    takingPhoto = true;
    camera.start();
    matrix = new float[][] {
      {1.0, 0.0, 0.0},
      {0.0, 1.0, 0.0},
      {0.0, 0.0, 1.0}
    };
    floatArray.reset();
    uv = new ArrayList<Float>(floatArray.getContent());    
  }
  
  public void hide()
  {
    if(takingPhoto)
    {
      camera.stop();
    }
    
    for(Integer i = 0; i < uv.size(); i += 2)
    {
      float[] point = new float[] {uv.get(i), uv.get(i+1), 1.0};
      point = Mat.multiply(matrix, point);
      uv.set(i, point[0]);
      uv.set(i+1, point[1]);
    }
    floatArray.setContent(uv);
    triangles.setImage(photo);
  }
  
  public void draw() throws Exception
  {
    
    pApplet.background(0,0,0);          
    if(takingPhoto)
    {
      camera.read();
      graphics.beginDraw();
      graphics.translate(0, cameraWidth);
      graphics.rotate(-pApplet.HALF_PI);    
      graphics.image(camera, 0, 0);
      graphics.endDraw();
      pApplet.image(graphics, left, top, right, bottom);
    }
    else
    {
      pApplet.pushMatrix();
      
      pApplet.applyMatrix(
        right-left, 0.0, 0.0, left,
        0.0, top-bottom, 0.0, bottom,
        0.0, 0.0, 1.0, 0.0,
        0.0, 0.0, 0.0, 1.0    
      );
      
      pApplet.pushMatrix();
      pApplet.applyMatrix(
        1.0, 0.0, 0.0, 0.0,
        0.0, -1.0, 0.0, 1.0,
        0.0, 0.0, 1.0, 0.0,
        0.0, 0.0, 0.0, 1.0
      );
      pApplet.image(photo, 0, 0, 1, 1);
      pApplet.popMatrix();
      
      pApplet.applyMatrix(
        matrix[0][0],    matrix[0][1],    0.0,             matrix[0][2],
        matrix[1][0],    matrix[1][1],    0.0,             matrix[1][2],
        0.0,             0.0,             1.0,             0.0,
        matrix[2][0],    matrix[2][1],    0.0,             matrix[2][2]
      );     
      
      /*for(Integer i = 0; i < uv.size(); i += 2)
      {
        pApplet.ellipse(uv.get(i), uv.get(i+1),0.01,0.01);
      }*/
      
      
      pApplet.pushMatrix();
      pApplet.applyMatrix(
        1.0, 0.0, 0.0, 0.0,
        0.0, -1.0, 0.0, 1.0,
        0.0, 0.0, 1.0, 0.0,
        0.0, 0.0, 0.0, 1.0
      );
      pApplet.image(uvImage, 0, 0, 1, 1);
      pApplet.popMatrix();      
      
      
      pApplet.popMatrix();      
    }
  }  
  
  public void onTap(PVector position)
  {
    if(takingPhoto)
    {
      graphics.beginDraw();
      graphics.translate(0, cameraWidth);
      graphics.rotate(-pApplet.HALF_PI);    
      graphics.image(camera.get(), 0, 0);
      graphics.endDraw();      
      photo = graphics.get();
      camera.stop();    
      takingPhoto = false; 
    }    
  }
  
  public void mouseDragged(PVector mousePosition) throws Exception
  {
    if(dragging)
    {
      PVector delta = PVector.sub(mousePosition,previousMousePosition);
      matrix[0][2] += delta.x / (right - left);
      matrix[1][2] -= delta.y / (bottom - top);
    }
    super.mouseDragged(mousePosition);    
  }
  
  public void mousePressed(PVector position) throws Exception
  {
    dragging = true;
    super.mousePressed(position);
  }
  
  public void mouseReleased(PVector position) throws Exception
  {
    dragging = true;
    super.mouseReleased(position);    
  }
  
  public void onFlick(PVector end, PVector start, Float speed) throws Exception
  {
    super.onFlick(end, start, speed);
    dragging = true;
  }
  
  public void onPinch(PVector position, Float distance) throws Exception
  {
    super.onPinch(position, distance);
    dragging = false;    
    if(position.x >= 0.8 * pApplet.width  && position.y > 0.2 * pApplet.height)
    {
      matrix[1][1] *= (pApplet.height + distance) / pApplet.height;      
    }
    else if(position.x < pApplet.width * 0.8 && position.y <= 0.2 * pApplet.height)
    {
      matrix[0][0] *= (pApplet.width + distance) / pApplet.width;      
    }
  }

  public void onRotate(PVector position, Float angle) throws Exception
  {
    super.onRotate(position, angle);
    dragging = false;    
    Float c = pApplet.cos(-angle);
    Float s = pApplet.sin(-angle);
    float[][] rotation = new float[][] {
      {c, -s, -0.5*c + 0.5*s + 0.5},
      {s,  c, -0.5*s - 0.5*c + 0.5},
      {0.0, 0.0, 1.0}
    };
    matrix = Mat.multiply(matrix, rotation);
  }
}
