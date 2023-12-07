# 宇浩・星陳輸入方案

本方案爲採用**繁體簡碼**的**宇浩・星陳**輸入方案，方案設計來自[rime-xuma][rime-xuma]，碼表來自[宇浩官方版][yuhao-github]。

## 使用介紹

- 字集選擇（輸入時按 `Ctrl + O` 切換）：
  
  - 常用： 常用繁體 + 部分異體字（例：爲(為)、衆(眾)等字）+ 部分日本漢字，共計9600多個。
  
  - 全集： 不過濾字集

- 三重註解： 支持 *拆分* + *編碼* + *拼音* 提示。`Ctrl + C` 關閉註解，`Ctrl + Shift + C` 可以切換註解顯示等級。詳情參攷 [rime-xuma][rime-xuma] 。

   想要正確顯示拆分的字根，需要安裝對應的字體。下載安裝[字體下載][yuhao-github] 中的 `fonts/YuhaoSongti.ttf`。

- 反查： `z`（小寫）反查，`zP`拼音反查，`zB` 五筆畫反查。

- 繁入簡出： 輸入繁體編碼，輸出簡化字（規範字），全局快捷鍵 `Ctrl + Shift + Space` 。

- 全碼後置： 簡碼單字排序靠前，全碼重碼時降低排序，讓位於無簡碼字詞。默認開啓。

- 手動造詞： 使用``` ` ```（反引號）引導，使用``` ` ```（反引號）分詞。如：``` `xxxx`xx`xx ```

- 選重： `;`（分號）次選，`'`（引號）三選。

- 單字模式：方案默認啟用了詞組，但也可通過 `詞組派 → 單字派` 選項進行切換。

- 符號： 可以使用 `/` 引導符號，比如，`/sx` 的候選有 `1. ± 2. ÷ 3. × 4. ∈ 5. ∏` 。
  
## 使用方案

複製目錄下所有文件到用戶文件夾，啓用方案（編輯用戶文件或在圖形界面勾選）後重新部署。

**註： Rime 版本必須大於 `1.8.5`， 對應小狼毫版本 `0.15.0` 。**

**註： 確保你的發行版支持 `librime-lua` 插件。**

**註： 確保你已經有朙月拼音和五筆劃方案，否則不能部署成功。**

## Tips

1. 關閉四碼唯一時自動上屏

   **以下代碼在開頭都標註了文件名，若不存在，需手動創建，下同。**

   ```yaml
   # yustar_trad.custom.yaml
   patch:
      speller/auto_select: false
   ```

2. 關閉四碼空碼時下一碼清屏

   ```yaml
   # yustar_trad.custom.yaml
   patch: 
      speller/auto_clear: none # 可選有：manual（手動空格清屏），auto（空碼自動清屏），max_length（四碼時空碼頂字清屏，默認）
   ```

3. 開啓逐字提示（不完全匹配）

   ```yaml
   # yustar_trad.custom.yaml
   patch: 
      translator/enable_completion: true 
   ```

4. 關閉造詞時逐字提示

   ```yaml
   # yustar_trad.custom.yaml
   patch: 
      encode_sentence/enable_completion: false
   ```

## Q&A

1. Q： 爲什麼部署不成功？

   A： 確保你已經有朙月拼音和五筆劃方案，部分發行版（例如同文輸入法）並不內置，需要手動下載。 [朙月拼音](https://github.com/rime/rime-luna-pinyin) [五筆畫](https://github.com/rime/rime-stroke)

2. Q： 爲什麼部分功能無法使用（如字集過濾）？

   A： 確保你的發行版支持 lua 插件。

3. Q： 如何刪除用戶自造詞？

   A:  
      > 删除特定用户词：输入该词编码，移动光标选中该词，敲删词键 Ctrl + Delete 或 Shift + Delete （Mac OS 用 Shift + Fn + Delete），默认还绑定了 Ctrl + K。删除整个用户词典：先退出输入法程序或算法服务， 然后删除用户目录下的 huma_trad.userdb 目录，再启动输入法。

4. Q： 與官方碼表不同之處

   A： **除了部分字使用了「T」源編碼外，其餘均爲「G」源編碼。詳見: [#1](https://github.com/ywxt/rime-yustar/issues/1)**
  
## License

本方案基於[宇浩输入法][yuhao-license]，分發碼表時請遵守其相關協議。

其他部分採用 [MIT][mit-license] 協議。

[rime-xuma]: https://github.com/Ace-Who/rime-xuma
[yuhao-github]: http://hgithub.com/forFudan/yuhao
[yuhao-license]: yuhao-LICENSE
[mit-license]: LICENSE
