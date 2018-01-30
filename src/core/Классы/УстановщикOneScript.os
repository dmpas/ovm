#Использовать 1commands
#Использовать fs
#Использовать tempfiles

Перем ЭтоWindows;
Перем Лог;

Процедура УстановитьOneScript(Знач ВерсияКУстановке) Экспорт
	
	Лог.Информация("Установка OneScript %1...", ВерсияКУстановке);

	ПроверитьКорректностьПереданнойВерсии(ВерсияКУстановке);
	
	КаталогУстановки = ПараметрыOVM.КаталогУстановкиПоУмолчанию();
	КаталогУстановкиВерсии = ОбъединитьПути(КаталогУстановки, ВерсияКУстановке);
	ФС.ОбеспечитьКаталог(КаталогУстановки);
	ФС.ОбеспечитьПустойКаталог(КаталогУстановкиВерсии);
	
	Лог.Отладка("Каталог установки версии: %1", КаталогУстановкиВерсии);

	ФайлУстановщика = СкачатьФайлУстановщика(ВерсияКУстановке);
		
	УстановитьOneScriptИзZipАрхива(ФайлУстановщика, КаталогУстановкиВерсии);
	ДобавитьSHScriptПриНеобходимости(КаталогУстановкиВерсии);
	
	Лог.Информация("Установка OneScript %1 завершена", ВерсияКУстановке);
	Лог.Информация("");

КонецПроцедуры

Функция СкачатьФайлУстановщика(Знач ВерсияКУстановке)
	
	Лог.Информация("Скачиваю установщик версии %1...", ВерсияКУстановке);

	ПутьКСохраняемомуФайлу = ВременныеФайлы.НовоеИмяФайла("zip");
	
	Ресурс = ПолучитьПутьКСкачиваниюФайла(ВерсияКУстановке);
	Соединение = Новый HTTPСоединение("http://oscript.io");
	Запрос = Новый HTTPЗапрос(Ресурс);
	
	Лог.Отладка("Сервер: %1. Ресурс: %2", Соединение.Сервер, Ресурс);

	Ответ = Соединение.Получить(Запрос, ПутьКСохраняемомуФайлу);
	Лог.Отладка("Код состояния: %1", Ответ.КодСостояния);

	Лог.Информация("Скачивание завершено");

	Если Ответ.КодСостояния <> 200 Тогда
		Лог.Ошибка(
			"Ошибка скачивания установщика. Текст ответа: 
			|%1", 
			Ответ.ПолучитьТелоКакСтроку()
		);
		ВызватьИсключение Ответ.КодСостояния;
	КонецЕсли;
	
	Лог.Отладка("Файл установщика скачан: %1", ПутьКСохраняемомуФайлу);
	
	Возврат ПутьКСохраняемомуФайлу;
	
КонецФункции

Процедура УстановитьOneScriptИзZipАрхива(Знач ПутьКФайлуУстановщика, Знач КаталогУстановкиВерсии)
	
	Лог.Информация("Распаковка OneScript...");

	ЧтениеZIPФайла = Новый ЧтениеZipФайла(ПутьКФайлуУстановщика);
	ЧтениеZIPФайла.ИзвлечьВсе(КаталогУстановкиВерсии);
	ЧтениеZIPФайла.Закрыть();
	
КонецПроцедуры

Процедура ДобавитьSHScriptПриНеобходимости(Знач КаталогУстановкиВерсии)
	
	Если ЭтоWindows Тогда
		Возврат;
	КонецЕсли;
	
	Лог.Информация("Создание sh-скрипта...");

	ПутьКСкрипту = ОбъединитьПути(КаталогУстановкиВерсии, "bin", "oscript");

	Лог.Отладка("Путь с sh-скрипту: %1", ПутьКСкрипту);

	Если ФС.ФайлСуществует(ПутьКСкрипту) Тогда
		Лог.Отладка("sh-скрипт уже существует");
		Возврат;
	КонецЕсли;

	ТекстСкрипта = 
	"#!/bin/sh
	|dirpath=`dirname $0`
	|mono $dirpath / oscript.exe ""$@""";
	
	Лог.Отладка(
		"Текст скрипта: 
		|%1",
		ТекстСкрипта
	);

	ЗаписьТекста = Новый ЗаписьТекста(ПутьКСкрипту, , , , Символы.ПС);
	
	ЗаписьТекста.Записать(ТекстСкрипта);
	ЗаписьТекста.Закрыть();
	
	Лог.Отладка("Установка флага выполнения...");

	Команда = Новый Команда;
	Команда.УстановитьКоманду("chmod");
	Команда.ДобавитьПараметр("+x");
	Команда.ДобавитьПараметр(ПутьКСкрипту);
	
	КодСостояния = Команда.Исполнить();
	Лог.Отладка(Команда.ПолучитьВывод());

	Если КодСостояния <> 0 Тогда
		Лог.Ошибка("Ошибка установки флага выполнения для sh-скрипта");
		Лог.Ошибка(Команда.ПолучитьВывод());

		ВызватьИсключение КодСостояния;
	КонецЕсли;
	
КонецПроцедуры

Процедура ПроверитьКорректностьПереданнойВерсии(Знач ВерсияКУстановке)
	Если СтрРазделить(ВерсияКУстановке, ".").Количество() <> 3
		И НРег(ВерсияКУстановке) <> "stable"
		И НРег(ВерсияКУстановке) <> "dev" Тогда
		
		Лог.Ошибка("Версия имеет некорректный формат");

		ВызватьИсключение ВерсияКУстановке;
	КонецЕсли;
КонецПроцедуры

Функция ПолучитьПутьКСкачиваниюФайла(Знач ВерсияКУстановке)
	
	Если СтрРазделить(ВерсияКУстановке, ".").Количество() = 3 Тогда
		КаталогВерсии = СтрЗаменить(ВерсияКУстановке, ".", "_");
	ИначеЕсли НРег(ВерсияКУстановке) = "stable" Тогда
		КаталогВерсии = "latest";
	ИначеЕсли НРег(ВерсияКУстановке) = "dev" Тогда
		КаталогВерсии = "night-build";
	Иначе
		ВызватьИсключение "Ошибка получения пути к файлу по версии";
	КонецЕсли;
	ИмяФайла = "zip";
	
	Ресурс = СтрШаблон("downloads/%1/%2", КаталогВерсии, ИмяФайла);
	Возврат Ресурс;
	
КонецФункции

СистемнаяИнформация = Новый СистемнаяИнформация;
ЭтоWindows = Найти(ВРег(СистемнаяИнформация.ВерсияОС), "WINDOWS") > 0;

Лог = ПараметрыOVM.ПолучитьЛог();
