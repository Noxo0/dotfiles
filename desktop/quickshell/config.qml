// FedDeck - Quickshell Configuration
// Cohesive shell design

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects

ShellRoot {
    id: root

    // Screen configuration
    Screen {
        id: screen
        available: true
    }

    // Main bar component
    Component {
        id: barComponent
        Rectangle {
            id: bar
            color: "transparent"

            // Live blur effect (like Ryoku)
            layer.enabled: true
            layer.effect: MultiEffect {
                blurEnabled: true
                blur: 1.0
                blurMax: 64
                saturation: 0.8
            }

            // Frame that retints from wallpaper
            Rectangle {
                anchors.fill: parent
                color: Qt.rgba(0.0, 0.0, 0.0, 0.3)
                radius: 12
            }

            // Bar content
            RowLayout {
                anchors.fill: parent
                anchors.margins: 8
                spacing: 16

                // Left side: Workspaces and launcher
                RowLayout {
                    spacing: 12

                    // Workspace indicator
                    Repeater {
                        model: 5
                        Rectangle {
                            width: 8
                            height: 8
                            radius: 4
                            color: index === activeWorkspace ? "#ffffff" : "#ffffff44"
                            opacity: index <= activeWorkspace ? 1.0 : 0.3
                        }
                    }

                    // Launcher trigger
                    Text {
                        text: "⌘"
                        font.pixelSize: 18
                        color: "#ffffff"
                        opacity: launcherArea.containsMouse ? 1.0 : 0.7
                        MouseArea {
                            id: launcherArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: launcherPopup.open()
                        }
                    }
                }

                Item { Layout.fillWidth: true }

                // Right side: Status widgets
                RowLayout {
                    spacing: 12

                    // Clock
                    Text {
                        text: Qt.formatDateTime(new Date(), "HH:mm")
                        font.pixelSize: 14
                        font.family: "JetBrains Mono"
                        color: "#ffffff"
                    }

                    // Date
                    Text {
                        text: Qt.formatDateTime(new Date(), "MMM dd")
                        font.pixelSize: 12
                        color: "#ffffffcc"
                    }

                    // System tray placeholder
                    Rectangle {
                        width: 24
                        height: 24
                        radius: 12
                        color: "#ffffff22"
                    }
                }
            }

            // Hover effect for popout cards (Ryoku-style)
            scale: barArea.containsMouse ? 1.02 : 1.0
            Behavior on scale {
                NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
            }

            MouseArea {
                id: barArea
                anchors.fill: parent
                hoverEnabled: true
            }
        }
    }

    // Launcher popup
    Popup {
        id: launcherPopup
        width: 600
        height: 400
        modal: true
        dim: true

        background: Rectangle {
            color: "#0a0a0a"
            radius: 16
            border.color: "#ffffff22"
            border.width: 1

            // Blur effect
            layer.enabled: true
            layer.effect: MultiEffect {
                blurEnabled: true
                blur: 0.5
                blurMax: 32
            }
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 16

            // Search input
            TextField {
                id: searchInput
                Layout.fillWidth: true
                placeholderText: "Search apps, commands, files..."
                font.pixelSize: 16
                background: Rectangle {
                    color: "#ffffff11"
                    radius: 8
                    border.color: searchInput.activeFocus ? "#ffffff44" : "transparent"
                    border.width: 1
                }
            }

            // Results list (placeholder)
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "transparent"
                Text {
                    anchors.centerIn: parent
                    text: "Launcher results"
                    color: "#ffffff66"
                }
            }
        }
    }

    // Initialize bar on each screen
    Repeater {
        model: Qt.application.screens
        Loader {
            sourceComponent: barComponent
            x: modelData.geometry.x
            y: modelData.geometry.y
            width: modelData.geometry.width
            height: 48
        }
    }

    // Properties
    property int activeWorkspace: 1
}
