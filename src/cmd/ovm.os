#Использовать cli
#Использовать tempfiles

#Использовать "."
#Использовать "../core"

///////////////////////////////////////////////////////////////////////////////

Процедура ВыполнитьКоманду(Знач КомандаПриложения) Экспорт
	
	КомандаПриложения.ВывестиСправку();
	
КонецПроцедуры

Процедура ВыполнитьПриложение()
	
	КонсольноеПриложение = Новый КонсольноеПриложение(ПараметрыПриложения.ИмяПриложения(), "OneScript Version Manager v" + ПараметрыПриложения.Версия());
	КонсольноеПриложение.Версия("v version", ПараметрыПриложения.Версия());
	
	КонсольноеПриложение.ДобавитьКоманду("install i", "Установить OneScript указанных версий", Новый КомандаInstall());
	КонсольноеПриложение.ДобавитьКоманду("use u", "Использовать OneScript указанной версии", Новый КомандаUse());
	КонсольноеПриложение.ДобавитьКоманду("uninstall delete d", "Удалить OneScript указанных версий", Новый КомандаUninstall());
	КонсольноеПриложение.ДобавитьКоманду("list ls", "Вывести список установленных и/или доступных версий OneScript", Новый КомандаList());
	КонсольноеПриложение.ДобавитьКоманду("run r", "Запустить исполняемый файл в окружении указанной версии OneScript", Новый КомандаRun());
	КонсольноеПриложение.ДобавитьКоманду("which w", "Вывести путь к установленной версии OneScript", Новый КомандаWhich());
	КонсольноеПриложение.ДобавитьКоманду("migrate", "Поместить установленный системный OneScript под контроль ovm. Только для Windows", Новый КомандаMigrate());
	
	КонсольноеПриложение.УстановитьОсновноеДействие(ЭтотОбъект);
	КонсольноеПриложение.Запустить(АргументыКоманднойСтроки);
	
КонецПроцедуры

Лог = ПараметрыOVM.ПолучитьЛог();
КодСостояния = 0;
Попытка
	ВыполнитьПриложение();
Исключение
	Лог.Ошибка(ОписаниеОшибки());
	КодСостояния = 1;
КонецПопытки;

ВременныеФайлы.Удалить();

ЗавершитьРаботу(КодСостояния);
