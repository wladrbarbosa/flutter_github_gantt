# Flutter Github Gantt

Based on https://github.com/lamact/react-issue-ganttchart. Thanks to lamact for this.

This application aims to be a facilitator for those who want to organize themselves regarding their projects hosted on github, providing a schedule with the issues of their repositories through a gantt chart.

![image](https://user-images.githubusercontent.com/10834873/132966421-87df65b0-acaa-400d-b907-13b4a55b2f63.png)

![image](https://user-images.githubusercontent.com/10834873/156359231-c491b68a-46da-438c-81e3-f2d3ff73f634.png)

## Installation

1. Install Flutter 2.10.1 SDK
1. Download or clone the code from this repository
1. In root folder, run on terminal `flutter run`
1. Done

## Using

1. You will need a Personal Token from your github user settings
1. Insert it on text field on top of page
1. Select a repository on right of it 

## Class Diagram generation and exportation

1. Type in the terminal: `flutter pub run dcdg -o don dcdg -o docs/diagram.puml`. -o is the output location.
1. Open the diagram file inside vscode and type Ctrl + Shift + P
1. Type PlantUML and search for PlantUML: Export Current Diagram

![image](out/docs/diagram/diagram.png)

## Features

    ✔️ Repo selection based on collaboration and not on ownerity
    ✔️ Expand, collapse and drag divider between the chart and the list of issues
    ✔️ Right mouse button on chart grid empty space for: add days on start of interval, add days on end of the interval, add new issue
    ✔️ Right mouse button on issue (chart or list) to edit an issue
    ✔️ Right mouse button with multiple issues selected (chart or list) to delete or invert state (open/closed) of it 
    ✔️ Ctrl + left mouse button for multiselection
    ✔️ Ctrl + shift + left mouse button for sequencial selection
    ✔️ Alt + scroll wheel for zoom in and out
    ✔️ Colors: green for closed, red for open and purple for open and late
    ✔️ Blue column for today
    ✔️ Select (yellow border issues) and drag to change scheduling
    ✔️ "About" screen for visualize app version and rate limits informations
    ✔️ Show dependencies on Gantt Chart
    ✔️ Edit dependencies on issue update dialog
