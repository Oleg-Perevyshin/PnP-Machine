// Получить ссылку на камеру
var camera = machine.defaultHead.defaultCamera;

// Переместить камеру туда, где была размещена деталь
camera.moveTo(placementLocation);

// Устанавливить камеру и зафиксировать изображение
var image = camera.settleAndCapture();

// Получить текущую дату и подготовить формат
var t = new Date();
var timeStr = t.toISOString();
timeStr = timeStr.replace('T','_');
timeStr = timeStr.replace(':','-');
timeStr = timeStr.replace(':','-');
timeStr = timeStr.slice(0,-5);

// Задать имя файла и путь к папке с кадрами
var fileName = String('/Users/POE/.openpnp/vision/' + timeStr + '_' + placement.getId() + '.png')
print('save placement image to ' + fileName);

// Запись изображения в файл
var file = new java.io.File(fileName);
javax.imageio.ImageIO.write(image, "PNG", file);