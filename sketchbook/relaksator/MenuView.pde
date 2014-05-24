import java.util.List;
import java.util.ArrayList;
import java.util.Arrays;

import controlP5.ControlP5;
import controlP5.Button;


public class MenuView extends View
{
  private ControlP5 controlP5;
  private List<String> buttonNames;
  private List<String> buttonLabels;
  private List<Button> buttons;
  private Integer buttonWidth;
  private Integer buttonHeight;  
  private Float spacerCoefficient;
  private Integer spacerHeight;  
  private color backgroundColor;
  private color passiveButtonColor;
  private color activeButtonColor;
  private color buttonLabelColor;
  private Float buttonLabelCoefficient;
  private PFont buttonLabelFont;
  private List<Integer> buttonLabelWidths;
  private List<Integer> fontSizes;
  
  public MenuView(PApplet pApplet, ControlP5 controlP5)
  {
    super(pApplet);
    this.controlP5 = controlP5;
    
    buttonNames = Arrays.asList("captureFaceAction","quitAction");
    buttonLabels = Arrays.asList("CAPTURE FACE", "QUIT");
    fontSizes = Arrays.asList(192,161,135,113,95,79,67,56,47,39,32,27,23,19,16,13,11,9,8,7,5,4,3);
    
    buttons = new ArrayList<Button>();
    
    spacerCoefficient = 0.05;
    buttonLabelCoefficient = 0.95;

    buttonWidth = pApplet.width;
    buttonHeight = int(pApplet.height / (buttonNames.size() * 1 + (buttonNames.size() - 1) * spacerCoefficient));
    spacerHeight = int(buttonHeight * spacerCoefficient);
    
    while(buttonNames.size() * buttonHeight + (buttonNames.size() - 1) * spacerHeight < pApplet.height)
    {
      ++spacerHeight;
    }
    
    backgroundColor = color(0,0,50);
    passiveButtonColor = color(50,50,100);
    activeButtonColor = color(70,70,100);
    buttonLabelColor = color(255,255,255);
    
    fontLoop: for(Integer fontSize : fontSizes)
    {  
      if(fontSize > buttonHeight * buttonLabelCoefficient)
      {
        continue; 
      }
      buttonLabelFont = pApplet.loadFont("Cyklop-Regular-"+String.valueOf(fontSize)+".vlw");
      pApplet.textFont(buttonLabelFont);
      for(String buttonLabel : buttonLabels)
      {  
        if(pApplet.textWidth(buttonLabel) > buttonWidth * buttonLabelCoefficient)
        {
          continue fontLoop;
        }
      }
      break;
    }
    
    buttonLabelWidths = new ArrayList<Integer>();
    
    for(String buttonLabel : buttonLabels)
    {
      buttonLabelWidths.add(int(pApplet.textWidth(buttonLabel)));
    }
    
    for(Integer i = 0; i < buttonNames.size(); ++i)
    {
      Button button = controlP5
        .addButton(buttonNames.get(i))
        .hide()
        .setPosition(0,i * (buttonHeight + spacerHeight))
        .setWidth(buttonWidth)
        .setHeight(buttonHeight)
        .setCaptionLabel(buttonLabels.get(i))
        .setColorBackground(passiveButtonColor)
        .setColorActive(activeButtonColor)
        .setColorCaptionLabel(buttonLabelColor);

      button.getCaptionLabel()
        .setFont(buttonLabelFont)
        .setPaddingX((buttonWidth - buttonLabelWidths.get(i))/2);

      buttons.add(button);     
    }
  }
  
  public void show()
  {
    for(Button button : buttons)
    {
      button.show();
    }
  }
  
  public void hide()
  {
    for(Button button : buttons)
    {
      button.hide();
    }    
  }  
  
  public void draw()
  {
    background(backgroundColor);
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
