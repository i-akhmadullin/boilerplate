## Установка ##
1. `npm install --silent`  
2. `grunt bower`  
3. `grunt sprite`
4. `grunt` или `grunt livereload`  
5. `grunt publish`  
  
`grunt publish_img` - очищает `/publish` от картинок(кроме sprite.png),  
копирует в неё картинки из `/blocks` кроме картинок для спрайта и пожимает их.  
  
`grunt sprite` - сборка картинок с `_sprite` в конце названия файла в `publish/sprite.png`  
плюс файл координат для спрайта в `blocks/sprite_position.styl`. Стили не пересобирает!  
