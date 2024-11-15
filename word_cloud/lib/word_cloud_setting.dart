import 'dart:math';
import 'package:flutter/material.dart';
import 'package:word_cloud/word_cloud_shape.dart';

class WordCloudSetting {
  double mapX = 0;
  double mapY = 0;
  String? fontFamily;
  FontStyle? fontStyle;
  FontWeight? fontWeight;
  List<Map> data = [];
  List map = [[]];
  List textCenter = [];
  List textPoints = [];
  List textlist = [];
  List isdrawed = [];
  double centerX = 0;
  double centerY = 0;
  double minTextSize;
  double maxTextSize;
  WordCloudShape shape;
  int attempt;
  List<Color>? colorList = [Colors.black];

  WordCloudSetting({
    Key? key,
    required this.data,
    required this.minTextSize,
    required this.maxTextSize,
    required this.attempt,
    required this.shape,
  });

  void setMapSize(double x, double y) {
    mapX = x;
    mapY = y;
  }

  void setColorList(List<Color>? colors) {
    colorList = colors;
  }

  void setFont(String? family, FontStyle? style, FontWeight? weight) {
    fontFamily = family;
    fontStyle = style;
    fontWeight = weight;
  }

  List setMap(dynamic shape) {
    List makemap = [[]];
    switch (shape.getType()) {
      case 'normal':
        for (var i = 0; i < mapX; i++) {
          for (var j = 0; j < mapY; j++) {
            makemap[i].add(0);
          }
          makemap.add([]);
        }
        break;

      case 'circle':
        for (var i = 0; i < mapX; i++) {
          for (var j = 0; j < mapY; j++) {
            if (pow(i - (mapX / 2), 2) + pow(j - (mapY / 2), 2) >
                pow(shape.getRadius(), 2)) {
              makemap[i].add(1);
            } else {
              makemap[i].add(0);
            }
          }
          makemap.add([]);
        }
        break;

      case 'ellipse':
        for (var i = 0; i < mapX; i++) {
          for (var j = 0; j < mapY; j++) {
            if (pow(i - (mapX / 2), 2) / pow(shape.getMajorAxis(), 2) +
                    pow(j - (mapY / 2), 2) / pow(shape.getMinorAxis(), 2) >
                1) {
              makemap[i].add(1);
            } else {
              makemap[i].add(0);
            }
          }
          makemap.add([]);
        }
        break;
    }
    return makemap;
  }

  void setInitial() {
    textCenter = [];
    textPoints = [];
    textlist = [];
    isdrawed = [];

    centerX = mapX / 2;
    centerY = mapY / 2;

    map = setMap(shape);

    for (var i = 0; i < data.length; i++) {
      double denominator =
          (data[0]['value'] - data[data.length - 1]['value']) * 1.0;
      double getTextSize;
      if (denominator != 0) {
        getTextSize = (minTextSize * (data[0]['value'] - data[i]['value']) +
                maxTextSize *
                    (data[i]['value'] - data[data.length - 1]['value'])) /
            denominator;
      } else {
        getTextSize = (minTextSize + maxTextSize) / 2;
      }

      final textSpan = TextSpan(
        text: data[i]['word'],
        style: TextStyle(
          color: colorList?[Random().nextInt(colorList!.length)],
          fontSize: getTextSize,
          fontWeight: fontWeight,
          fontFamily: fontFamily,
          fontStyle: fontStyle,
        ),
      );

      final textPainter = TextPainter()
        ..text = textSpan
        ..textDirection = TextDirection.ltr
        ..textAlign = TextAlign.center
        ..layout();

      // テキストが描画エリアの幅を超える場合はスキップ
      if (textPainter.width > mapX) {
        continue; // この単語をスキップ
      }

      // 条件を満たす単語のみリストに追加
      textlist.add(textPainter);
      double centerCorrectionX = centerX - textlist.last.width / 2;
      double centerCorrectionY = centerY - textlist.last.height / 2;
      textCenter.add([centerCorrectionX, centerCorrectionY]);
      textPoints.add([]);
      isdrawed.add(false);
    }
  }

  void setTextStyle(List<TextStyle> newstyle) {
    //only support color, weight, family, fontstyle
    textlist = [];
    textCenter = [];
    textPoints = [];
    isdrawed = [];

    for (var i = 0; i < data.length; i++) {
      double getTextSize =
          (minTextSize * (data[0]['value'] - data[i]['value']) +
                  maxTextSize *
                      (data[i]['value'] - data[data.length - 1]['value'])) /
              (data[0]['value'] - data[data.length - 1]['value']);

      final textSpan = TextSpan(
        text: data[i]['word'],
        style: TextStyle(
          color: newstyle[i].color,
          fontSize: getTextSize,
          fontWeight: newstyle[i].fontWeight,
          fontFamily: newstyle[i].fontFamily,
          fontStyle: newstyle[i].fontStyle,
        ),
      );

      final textPainter = TextPainter()
        ..text = textSpan
        ..textDirection = TextDirection.ltr
        ..textAlign = TextAlign.center
        ..layout();

      textlist.add(textPainter);

      double centerCorrectionX = centerX - textlist[i].width / 2;
      double centerCorrectionY = centerY - textlist[i].height / 2;
      textCenter.add([centerCorrectionX, centerCorrectionY]);
      textPoints.add([]);
      isdrawed.add(false);
    }
  }

  bool checkMap(double x, double y, double w, double h) {
    if (mapX - x < w) {
      return false;
    }
    if (mapY - y < h) {
      return false;
    }
    for (int i = x.toInt(); i < x.toInt() + w; i++) {
      for (int j = y.toInt(); j < y.toInt() + h; j++) {
        if (map[i][j] == 1) {
          return false;
        }
      }
    }
    return true;
  }

  bool checkMapOptimized(int x, int y, double w, double h) {
    if (mapX - x < w) {
      return false;
    }
    if (mapY - y < h) {
      return false;
    }
    for (int i = x.toInt(); i < x.toInt() + w; i++) {
      if (map[i][y + h.toInt() - 1] == 1) {
        return false;
      }
      if (map[i][y + 1] == 1) {
        return false;
      }
    }
    return true;
  }

  void drawIn(int index, double x, double y) {
    textPoints[index] = [x, y];
    int width = textlist[index].width.toInt();
    int height = textlist[index].height.floor();

    for (int i = x.toInt(); i < x.toInt() + width; i++) {
      // `i` が `mapX` の範囲内に収まるようにチェック
      if (i < 0 || i >= mapX) continue;

      for (int j = y.toInt(); j < y.toInt() + height; j++) {
        // `j` が `mapY` の範囲内に収まるようにチェック
        if (j < 0 || j >= mapY) continue;

        map[i][j] = 1;
      }
    }
  }

  void drawTextOptimized() {
    if (textCenter.isEmpty) {
      return;
    }

    drawIn(0, textCenter[0][0], textCenter[0][1]);
    isdrawed[0] = true;
    bool checkattempt = false;
    for (var i = 1; i < textlist.length; i++) {
      double w = textlist[i].width;
      double h = textlist[i].height;

      // 単語の幅が描画エリアより大きい場合はスキップ
      if (w > mapX) {
        continue;
      }

      int attempts = 0;

      bool isadded = false;

      while (!isadded) {
        int getX = Random().nextInt(mapX.toInt() - w.toInt());
        int direction = Random().nextInt(2);
        if (direction == 0) {
          for (int y = textCenter[i][1].toInt(); y > 0; y--) {
            if (checkMapOptimized(getX, y, w, h)) {
              drawIn(i, getX.toDouble(), y.toDouble());
              isadded = true;
              isdrawed[i] = true;
              break;
            }
          }
        } else if (direction == 1) {
          for (int y = textCenter[i][1].toInt(); y < mapY; y++) {
            if (checkMapOptimized(getX, y, w, h)) {
              drawIn(i, getX.toDouble(), y.toDouble());
              isadded = true;
              isdrawed[i] = true;
              break;
            }
          }
        }
        attempts += 1;
        if (attempts > attempt) {
          isadded = true;
          checkattempt = true;
        }
      }
      if (checkattempt) {
        return;
      }
    }
  }

  void drawText() {
    drawIn(0, textCenter[0][0], textCenter[0][1]);
    for (var i = 1; i < textlist.length; i++) {
      double w = textlist[i].width;
      double h = textlist[i].height;

      // 単語の幅が描画エリアより大きい場合はスキップ
      if (w > mapX) {
        continue;
      }

      int attempts = 0;

      bool isadded = false;

      while (!isadded) {
        int getX = Random().nextInt(mapX.toInt() - w.toInt());
        int direction = Random().nextInt(2);
        if (direction == 0) {
          for (int y = textCenter[i][1].toInt(); y > 0; y--) {
            if (checkMap(getX.toDouble(), y.toDouble(), w, h)) {
              drawIn(i, getX.toDouble(), y.toDouble());
              isadded = true;
              break;
            }
          }
          if (!isadded) {
            for (int y = textCenter[i][1].toInt(); y < mapY; y++) {
              if (checkMap(getX.toDouble(), y.toDouble(), w, h)) {
                drawIn(i, getX.toDouble(), y.toDouble());
                isadded = true;
                break;
              }
            }
          }
        } else if (direction == 1) {
          for (int y = textCenter[i][1].toInt(); y < mapY; y++) {
            if (checkMap(getX.toDouble(), y.toDouble(), w, h)) {
              drawIn(i, getX.toDouble(), y.toDouble());
              isadded = true;
              break;
            }
          }
          if (!isadded) {
            for (int y = textCenter[i][1].toInt(); y > 0; y--) {
              if (checkMap(getX.toDouble(), y.toDouble(), w, h)) {
                drawIn(i, getX.toDouble(), y.toDouble());
                isadded = true;
                break;
              }
            }
          }
        }
        attempts += 1;
        if (attempts > attempt) {
          isadded = true;
        }
      }
    }
  }

  List getWordPoint() {
    return textPoints;
  }

  List getTextPainter() {
    return textlist;
  }

  int getDataLength() {
    return data.length;
  }
}
