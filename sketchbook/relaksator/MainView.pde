public static class MainView extends View
{
  protected ColladaScene scene = null; 
  protected Float angle = 0.0;
  
  public MainView(PApplet pApplet, Collada collada) throws Exception
  {
    super(pApplet, collada);

    scene = collada.getScene();    
  }
  
  public Collada getCollada()
  {
    return collada;
  }
  
  public void show()
  {
  }
  
  public void hide()
  {
  }
  
  public Float getAngle()
  {
    return angle;
  }
  
  public void setAngle(Float angle)
  {
    this.angle = angle - floor(angle / TWO_PI) * TWO_PI;
  }
  
  public void addAngle(Float angle)
  {
    setAngle(this.angle+angle);
  }
  
  public void draw() throws Exception
  {
    pApplet.pushStyle();
    pApplet.pushMatrix();    
    pApplet.background(0,0,0);
    pApplet.lights();    
    pApplet.translate(pApplet.width/2, pApplet.height/2, 0);
    pApplet.applyMatrix(
       1.0,  0.0,  0.0,  0.0,
       0.0, -1.0,  0.0,  0.0,
       0.0,  0.0,  1.0,  0.0,
       0.0,  0.0,  0.0,  1.0
    );
    pApplet.rotate(angle);
    
    if(pApplet.width/pApplet.height < 2/3)
    {
      pApplet.scale(0.01*pApplet.width*3/2); 
    }
    else
    {
      pApplet.scale(0.01*pApplet.height);
    }
    collada.run();
    //Long time = System.currentTimeMillis();
    scene.draw();
    //pApplet.println("scene draw: "+String.valueOf(System.currentTimeMillis()-time));
    pApplet.popMatrix();
    pApplet.popStyle();    
  }
  
  public void startRightHookAnimation() throws Exception
  {
    Long startTime = System.currentTimeMillis();
    ((ColladaAnimation)collada.getById("Bone001-anim")).start(startTime, 0*33l, 9*33l);
    ((ColladaAnimation)collada.getById("Bone002-anim")).start(startTime, 0*33l, 9*33l);
    ((ColladaAnimation)collada.getById("Bone003-anim")).start(startTime, 0*33l, 9*33l);
    ((ColladaAnimation)collada.getById("Bone004-anim")).start(startTime, 0*33l, 9*33l);      
  }
  
  public void startLeftHookAnimation() throws Exception
  {
    Long startTime = System.currentTimeMillis();
    ((ColladaAnimation)collada.getById("Bone001-anim")).start(startTime, 16*33l, 25*33l);
    ((ColladaAnimation)collada.getById("Bone002-anim")).start(startTime, 16*33l, 25*33l);
    ((ColladaAnimation)collada.getById("Bone003-anim")).start(startTime, 16*33l, 25*33l);
    ((ColladaAnimation)collada.getById("Bone004-anim")).start(startTime, 16*33l, 25*33l);      
  }
  
  public void startPunchAnimation() throws Exception
  {
    Long startTime = System.currentTimeMillis();
    ((ColladaAnimation)collada.getById("Bone001-anim")).start(startTime, 32*33l, 41*33l);
    ((ColladaAnimation)collada.getById("Bone002-anim")).start(startTime, 32*33l, 41*33l);
    ((ColladaAnimation)collada.getById("Bone003-anim")).start(startTime, 32*33l, 41*33l);
    ((ColladaAnimation)collada.getById("Bone004-anim")).start(startTime, 32*33l, 41*33l);      
  }
  
  public void startElectricityAnimation() throws Exception
  {
    Long startTime = System.currentTimeMillis();
    ((ColladaAnimation)collada.getById("Bone001-anim")).start(startTime, 48*33l, 65*33l);
    ((ColladaAnimation)collada.getById("Bone002-anim")).start(startTime, 48*33l, 65*33l);
    ((ColladaAnimation)collada.getById("Bone003-anim")).start(startTime, 48*33l, 65*33l);
    ((ColladaAnimation)collada.getById("Bone004-anim")).start(startTime, 48*33l, 65*33l);      
  }
  
  public void startShakingAnimation() throws Exception
  {
    Long startTime = System.currentTimeMillis();
    ((ColladaAnimation)collada.getById("Bone001-anim")).start(startTime, 72*33l, 81*33l);
    ((ColladaAnimation)collada.getById("Bone002-anim")).start(startTime, 72*33l, 81*33l);
    ((ColladaAnimation)collada.getById("Bone003-anim")).start(startTime, 72*33l, 81*33l);
    ((ColladaAnimation)collada.getById("Bone004-anim")).start(startTime, 72*33l, 81*33l);      
  }
  
  public void stopAnimation() throws Exception
  {
    ((ColladaAnimation)collada.getById("Bone001-anim")).stop();
    ((ColladaAnimation)collada.getById("Bone002-anim")).stop();
    ((ColladaAnimation)collada.getById("Bone003-anim")).stop();
    ((ColladaAnimation)collada.getById("Bone004-anim")).stop();       
  }
  
  public void onTap(PVector position) throws Exception
  {
    stopAnimation();
    startPunchAnimation();
  }
  
  public void onFlick(PVector end, PVector start, Float speed) throws Exception
  {
    PVector delta = PVector.sub(end,start);
    stopAnimation();
    if(delta.x >= 0)
    {
      startLeftHookAnimation();
    }
    else
    {
      startRightHookAnimation();
    }
  }
  
  public void onPinch(PVector position, Float distance) throws Exception
  {
    stopAnimation();
    startElectricityAnimation();
  }
  
  public void onRotate(PVector position, Float angle) throws Exception
  {
    stopAnimation();
    startShakingAnimation();
  }    
 
}
