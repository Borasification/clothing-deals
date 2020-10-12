import Editor from "discourse/components/d-editor";
import { on } from "@ember/object/evented";
import { schedule } from "@ember/runloop";
import { caretPosition } from "discourse/lib/utilities";
import { findRawTemplate } from "discourse-common/lib/raw-templates";

export default function () {
  Editor.reopen({
    _applyClothingDealsAutocomplete: on("didInsertElement", function () {
      const container = this.get("container");
      const $editorInput = this.$(".d-editor-input");

      const template = findRawTemplate("clothing-deals-autocomplete");

      $editorInput.autocomplete({
        template: template,
        dataSource(term) {
          return ["toto", "titi", "tata"];
        },
        key: "\u200b",
        onKeyUp: (text, cp) => {
          const match = /@bonplan /g.exec(text);

          if (!match || !match[0]) {
            return false;
          }

          // console.log(match);
          // const end = match.index + match[0].length;
          // console.log(cp, end + 1, cp === end + 1);
          // if (cp === end && match[0]) {
          //   return true;
          // }
          return [text + text];
        },
        // triggerRule: (textarea, opts) => {
        //   const pos = caretPosition(textarea);
        //   const match = /@bonplan/g.exec(textarea.value.substring(0, pos));

        //   if (!match) {
        //     console.log(match);
        //     return false;
        //   }
        //   const end = match.index + match[0].length;
        //   console.log(end);

        //   if (pos === end + 1) {
        //     return true;
        //   }

        //   return false;
        // },
      });
    }),
  });
}
