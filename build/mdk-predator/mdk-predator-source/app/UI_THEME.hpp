#ifndef UI_THEME_HPP
#define UI_THEME_HPP

#include "ui.hpp"

namespace ui {

// Colors defined using RGB components (PortaPack compatible)
// RGB565 format: RRRRRGGGGGGBBBBB
constexpr Color ACCENT_COLOR = Color(255, 140, 0);      // Orange
constexpr Color BACKGROUND_COLOR = Color(31, 31, 31);   // Dark gray
constexpr Color TEXT_COLOR = Color(224, 224, 224);      // Light gray
constexpr Color HEADER_COLOR = Color(255, 255, 255);    // White
constexpr Color BORDER_COLOR = Color(74, 74, 74);       // Medium gray

} // namespace ui

#endif // UI_THEME_HPP
