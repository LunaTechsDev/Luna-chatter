import rm.types.RPG.BaseItem;
import rm.core.Graphics;
import rm.Globals;
import Types.ChatterEvents;
import rm.scenes.Scene_Map as RmScene_Map;

using Lambda;

class SceneMap extends RmScene_Map {
  public var _notificationTimer: Int; // 5 seconds

  public function new() {
    super();
  }

  public override function initialize() {
    untyped _Scene_Map_initialize.call(this);
    this._notificationTimer = Main.CHParams.notificationStayTime;
  }

  public function setupLCNotificationEvents() {
    var listener = Main.ChatterEmitter;

    // Notifications
    listener.on(ChatterEvents.PUSHNOTIF, (text: String) -> {
      // Start Queue and Transition Window
      var win = Main.chatterWindows.pop();
      listener.emit(ChatterEvents.QUEUE, win);
      win.drawText(text, 0, 0, win.contentsWidth(), 'left');
    });

    listener.on(ChatterEvents.PUSHITEMNOTIF, (item: BaseItem, amount: Int) -> {
      var win = Main.chatterWindows.pop();
      listener.emit(ChatterEvents.QUEUE, win);
      var sign = amount > 0 ? '+' : '-';

      var textStr = '${item.name} \\I[${item.iconIndex}] ${sign} x${Math.abs(amount)}';
      #if compileMV
      win.drawTextEx(textStr, 0, 0);
      #else
      win.drawTextEx(textStr, 0, 0, win.contentsWidth());
      #end
    });

    listener.on(ChatterEvents.PUSHCHARNOTIF, (text: String, charImg: String, index: Int) -> {
      // Show Character face, then text
      var win = Main.chatterWindows.pop();
      win.drawCharacter(charImg, index, 0, 0);
      listener.emit(ChatterEvents.QUEUE, win);
      var charWidth = 48;
      #if compileMV
      win.drawTextEx(text, charWidth, 0);
      #else
      win.drawTextEx(text, charWidth, 0, win.contentsWidth());
      #end
    });

    listener.on(ChatterEvents.PUSHFACENOTIF, (text: String, faceName: String, faceIndex: Int) -> {
      var win = Main.chatterWindows.pop();
      var faceWidth = 50;
      win.drawFace(faceName, faceIndex, 0, 0, 50, win.contentsHeight());
      #if compileMV
      win.drawTextEx(text, faceWidth, 0);
      #else
      win.drawTextEx(text, faceWidth, 0, win.contentsWidth());
      #end
    });

    listener.on(ChatterEvents.QUEUE, (win: ChatterWindow) -> {
      // Reset Timer
      if (Main.chatterQueue.length == 0) {
        this._notificationTimer = Main.CHParams.notificationStayTime;
      }

      if (Main.chatterQueue.length > 0) {
        // Move all the windows down by amount when notification comes in
        // Update will be necessary to use window height later
        trace('Update chatter queue windows');
        Main.chatterQueue.iter(handleSlideMove);
      }
      Main.queueChatterWindow(win);
      switch (Main.CHParams.animationTypeNotification) {
        case SLIDE:
          this.handleSlideIn(win);
        case FADE:
          this.handleFadeIn(win);
      }
    });
    listener.on(ChatterEvents.DEQUEUE, () -> {
      var win = Main.dequeueChatterWindow();
      switch (Main.CHParams.animationTypeNotification) {
        case SLIDE:
          this.handleSlideOut(win);
        case FADE:
          this.handleFadeOut(win);
      }
      // Place the latest dequeued window back in the window list.
      Main.chatterWindows.unshift(win);
    });
  }

  public function handleSlideMove(win: ChatterWindow) {
    switch (Main.CHParams.anchorPosition) {
      case TOPLEFT:
        win.moveBy(0, 90);

      case TOPRIGHT:
        win.moveBy(0, 90);

      case BOTTOMLEFT:
        win.moveBy(0, -90);

      case BOTTOMRIGHT:
        win.moveBy(0, -90);
    }
  }

  public function handleSlideIn(win: ChatterWindow) {
    switch (Main.CHParams.anchorPosition) {
      case TOPLEFT:
        win.moveBy(win.width, 0);

      case TOPRIGHT:
        win.moveBy(-win.width, 0);

      case BOTTOMLEFT:
        win.moveBy(win.width, 0);

      case BOTTOMRIGHT:
        win.moveBy(-win.width, 0);
    }
  }

  public function handleSlideOut(win: ChatterWindow) {
    switch (Main.CHParams.anchorPosition) {
      case TOPLEFT:
        win.moveByWithFn(-win.width, 0, this.handleResetPosition);

      case TOPRIGHT:
        win.moveByWithFn(win.width, 0, this.handleResetPosition);

      case BOTTOMLEFT:
        win.moveByWithFn(-win.width, 0, this.handleResetPosition);

      case BOTTOMRIGHT:
        win.moveByWithFn(win.width, 0, this.handleResetPosition);
    }
  }

  public function handleFadeIn(win: ChatterWindow) {
    this.handleSlideIn(win);
    win.fadeTo(255);
  }

  public function handleFadeOut(win: ChatterWindow) {
    win.fadeToWithFn(0, this.handleResetPosition);
  }

  public function handleResetPosition(win: ChatterWindow) {
    var pos = switch (Main.CHParams.anchorPosition) {
      case BOTTOMLEFT:
        { x: -win.width, y: Graphics.boxHeight };
      case BOTTOMRIGHT:
        { x: Graphics.boxWidth, y: Graphics.boxHeight };
      case TOPLEFT:
        { x: -win.width, y: 0 }
      case TOPRIGHT:
        { x: Graphics.boxWidth, y: 0 };
    }
    win.moveTo(pos.x, pos.y);
  }

  public override function createAllWindows() {
    untyped _Scene_Map_createAllWindows.call(this);
    if (Main.CHParams.enableNotifications) {
      this.createAllLCWindows();
      this.setupLCNotificationEvents();
    }

    this.createAllLCEventWindows();
  }

  public function createAllLCWindows() {
    // Create notification windows based on maximum
    // keep them hidden until ready to use
    var width = 200;
    var height = 75;
    for (x in 0...Main.CHParams.maxChatterWindows) {
      var pos = switch (Main.CHParams.anchorPosition) {
        case BOTTOMLEFT:
          { x: -width, y: Graphics.boxHeight };
        case BOTTOMRIGHT:
          { x: Graphics.boxWidth, y: Graphics.boxHeight };
        case TOPLEFT:
          { x: -width, y: 0 }
        case TOPRIGHT:
          { x: Graphics.boxWidth, y: 0 };
      }
      var chatterWindow = new ChatterWindow(cast pos.x, cast pos.y, width, height);
      Main.chatterWindows.push(chatterWindow);
      this.addWindow(chatterWindow);
      trace('Created ', x + 1, ' windows');
    }
  }

  public function createAllLCEventWindows() {
    // Scan Events With Notetags to show event information
    var mapEvents = Globals.GameMap.events();
    // Add NoteTag Check Later -- + Add Events
    var re = ~/<lcevent:\s*(\w+)\s+(\w+)>/ig;
    var imgRe = ~/<lceventImg:\s*(\w+)\s+(\w+)>/ig;

    if (Main.CHParams.enableEventNames) {
      mapEvents.filter(event -> re.match(event.event().note) || imgRe.match(event.event().note)).iter((event) -> {
        var chatterEventWindow = new ChatterEventWindow(0, 0, 100, 100);
        chatterEventWindow.setEvent(event);

        this._spriteset.__characterSprites.iter((charSprite) -> {
          if (charSprite.x == event.screenX() && charSprite.y == event.screenY()) {
            chatterEventWindow.setEventSprite(charSprite);
            charSprite.addChild(chatterEventWindow);
            charSprite.bitmap.addLoadListener((_) -> {
              Main.positionEventWindow(chatterEventWindow);
            });
            chatterEventWindow.close();
          }
        });

        chatterEventWindow.setupEvents(cast this.setupGameEvtEvents);
        chatterEventWindow.open();
      });
    }
  }

  public function setupGameEvtEvents(currentWindow: ChatterEventWindow) {
    currentWindow.on(ChatterEvents.PLAYERINRANGE, (win: ChatterEventWindow) -> {
      if (!win.playerInRange) {
        openChatterWindow(win);
        win.playerInRange = true;
      }
    });

    currentWindow.on(ChatterEvents.PLAYEROUTOFRANGE, (win: ChatterEventWindow) -> {
      if (win.playerInRange) {
        closeChatterWindow(win);
        win.playerInRange = false;
      }
    });

    currentWindow.on(ChatterEvents.ONHOVER, (win: ChatterEventWindow) -> {
      if (!win.hovered && !win.playerInRange) {
        openChatterWindow(win);
        win.hovered = true;
      }
    });

    currentWindow.on(ChatterEvents.ONHOVEROUT, (win: ChatterEventWindow) -> {
      if (win.hovered) {
        closeChatterWindow(win);
        win.hovered = false;
      }
    });

    currentWindow.on(ChatterEvents.PAINT, (win: ChatterEventWindow) -> {
      win.drawByType(win.event.event().note, 0, 0, win.width, 'center');
    });
  }

  // ======================
  // Update Changes
  public override function update() {
    untyped _Scene_Map_update.call(this);
    this.updateChatterNotifications();
  }

  public function updateChatterNotifications() {
    if (this._notificationTimer > 0) {
      this._notificationTimer--;
    }
    if (Main.chatterQueue.length > 0 && this._notificationTimer == 0) {
      Main.ChatterEmitter.emit(ChatterEvents.DEQUEUE);
      // Reset Timer If Notifications Remain
      if (Main.chatterQueue.length > 0) {
        this._notificationTimer = Main.CHParams.notificationStayTime;
      }
    }
  }

  // ======================
  // Chatter Windows
  public function showChatterWindow(win: ChatterWindow) {
    win.show();
  }

  public function hideChatterWindow(win: ChatterWindow) {
    win.hide();
  }

  public function openChatterWindow(win: ChatterWindow) {
    win.open();
  }

  public function closeChatterWindow(win: ChatterWindow) {
    win.close();
  }
}
