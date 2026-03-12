# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

SmartFlow is a personal finance management system based on accounting principles (Assets = Liabilities + Owner's Equity). Pure frontend implementation.

## Core Documentation

- `docs/0. 项目概述.md` - Project overview and quick reference
- `docs/1. 核心业务模型.md` - Double-entry bookkeeping model and database schema
- `docs/2. 核心功能.md` - Core modules and features specification
- `docs/3. 项目整体开发规划.md` - Development roadmap with MVP and 6 phases
- `docs/4. 技术实现要点.md` - Technical implementation details
- `docs/5. 用户体验.md` - UX design and interaction patterns

## MCP
Always use Context7 MCP when I need library/API documentation, code generation, setup or configuration steps without me having to explicitly ask.

## Tech Stack

- **Frontend**: Vue 3 + Vite + TypeScript
- **State/Routing**: Pinia + Vue Router 4
- **Local Database**: Dexie.js
- **UI**: TailwindCSS + shadcn-vue
- **Charts**: ECharts (vue-echarts)
- **Utilities**: currency.js (monetary calculations), dayjs (date calculations), PapaParse (CSV parsing)
