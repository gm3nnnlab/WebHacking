# Інтеграція MDK-Predator з готовою firmware

## Крок 1: Завантажити pre-built firmware

### Перейди на:
https://github.com/portapack-mayhem/mayhem-firmware/releases

### Вибери найновіший릴리즈для PortaPack H4M:
- Шукай релізу позначений як "Latest" або "Nightly"
- Завантаж архів на зразок `mayhem_vX.X.X.zip` або `mayhem_nightly_YYYY-MM-DD.zip`
- Витяг архів в окрему папку, наприклад: `/tmp/mayhem-prebuilt/`

## Крок 2: Знайти application.bin

```bash
# Розпакуй архів
cd /tmp/mayhem-prebuilt
unzip mayhem_*.zip

# Знайди application.bin
find . -name "application.bin" -o -name "*.bin" | grep -i application
```

Повинна бути в:
- `firmware/application/application.bin` або
- `build/firmware/application/application.bin` або
- `dist/application.bin`

## Крок 3: Скопіювати в поточний проект

```bash
# Скопіюй готовий application.bin у наш build
cp /tmp/mayhem-prebuilt/*/application.bin \
   /home/user/WebHacking/build/mdk-predator/build/mayhem-firmware/build/

# Перевір що скопійовано
ls -lh /home/user/WebHacking/build/mdk-predator/build/mayhem-firmware/build/application.bin
```

## Крок 4: Генерувати .ppma файл

Якщо є export script в mayhem-firmware:

```bash
cd /home/user/WebHacking/build/mdk-predator/build/mayhem-firmware/build

# Спробуй запустити export script (якщо існує)
if [ -f ../firmware/application/export.sh ]; then
  bash ../firmware/application/export.sh
elif [ -f ../scripts/export_apps.sh ]; then
  bash ../scripts/export_apps.sh
else
  echo "Export script not found - check mayhem-firmware docs"
fi
```

## Крок 5: Альтернатива - Скопіювати готову .ppma (якщо є в releases)

Деякі releases включають попередньо скомпільовані .ppma файли:

```bash
# Шукай в папці release
find /tmp/mayhem-prebuilt -name "*.ppma"

# Якщо знайдено - скопіюй на PortaPack SD
cp /tmp/mayhem-prebuilt/**/*.ppma /path/to/portapack/sd/APPS/
```

## Крок 6: Розгорнути на PortaPack H4M

### Спосіб A: Через SD карту
1. Підключи SD карту PortaPack до комп'ютера
2. Скопіюй файл в папку `/APPS/`
3. Безпечно витягни SD карту
4. Вставь назад в PortaPack
5. Запусти: **Reciever** → **Applications** → **External Apps**

### Спосіб B: Через HackRF
```bash
# Якщо є утиліти для прошивання
hackrf_spiflash -w application.bin
```

## Перевірка

Після розгортання на PortaPack:
- Перейди в **Applications** → **External Apps**
- Повинна бути **MDK-Predator** у списку
- Запусти для перевірки що все працює

## Якщо щось не так

1. **Немає export script** - Використай готову .ppma з releases
2. **Помилка при запуску** - Перевір логи PortaPack
3. **Потребує реком файл** - Переконайся що SD карта має правильну структуру

## Документація

- Mayhem releases: https://github.com/portapack-mayhem/mayhem-firmware/releases
- PortaPack H4M guide: https://github.com/portapack-mayhem/mayhem-firmware/wiki

---

**Дати знати як пройде!**
