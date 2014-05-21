import controlP5.ControlP5;
import controlP5.Button;

public class MenuView extends View
{
  private ControlP5 controlP5 = null;
  private Button captureFaceButton = null;
  private Button quitButton = null;
  private Integer buttonCount;
  private Integer buttonWidth;
  private Integer buttonHeight;
  
  public MenuView(PApplet pApplet, ControlP5 controlP5)
  {
    super(pApplet);
    this.controlP5 = controlP5;
    
    buttonCount = 2;
    buttonWidth = pApplet.width;
    buttonHeight = pApplet.height / buttonCount;
    
    captureFaceButton = controlP5
      .addButton("captureFaceAction")
      .hide()
      .setPosition(0,0 * buttonHeight)
      .setWidth(buttonWidth)
      .setHeight(buttonHeight)
      .setCaptionLabel("Capture a photo");
    quitButton = controlP5
      .addButton("quitAction")
      .hide()
      .setPosition(0,1 * buttonHeight)
      .setWidth(buttonWidth)
      .setHeight(buttonHeight)
      .setCaptionLabel("Quit");         
  }
  
  public void show()
  {
    captureFaceButton.show();
    quitButton.show();
  }
  
  public void hide()
  {
    captureFaceButton.hide();
    quitButton.hide();
  }  
  
  public void draw()
  {
    background(0,0,50);   
  }  
  
  public void captureFaceAction()
  {
    println("OK");
  }
  
  public void quitAction()
  {
     exit();
  }
}
