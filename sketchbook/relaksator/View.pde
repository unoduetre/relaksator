public static abstract class View extends Widget
{
  protected PVector previousMousePosition = null;
  protected Collada collada = null;
  
  public View(PApplet pApplet, Collada collada)
  {
    super(pApplet);
    this.collada = collada;
  }

  public abstract void show();
  
  public abstract void hide();
  
  public void mousePressed(PVector mousePosition) throws Exception
  {
    previousMousePosition = mousePosition;
  }
  
  public void mouseReleased(PVector mousePosition) throws Exception
  {
    previousMousePosition = mousePosition;    
  }

  public void mouseDragged(PVector mousePosition) throws Exception
  {
    previousMousePosition = mousePosition;    
  }
  
  public void onFlick(PVector position, PVector delta, Float speed)
  {
  }
  
  public void onPinch(PVector position, Float distance)
  {
  }

  public void onRotate(PVector position, Float angle)
  {
  }  
}

