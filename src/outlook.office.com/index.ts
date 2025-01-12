import { waitForIdle, waitForElement, deleteElement, watchForElement, makeElement } from "../lib/common.js";

import hljs from "highlight.js";

const highlightedCodeCache = new Map<string, string>();

async function main() {
	document.head.appendChild(makeElement("link", {
		rel:  "stylesheet",
		type: "text/css",
		href: "https://cdn.jsdelivr.net/gh/highlightjs/highlight.js/src/styles/atom-one-dark.css",
	}));

	await waitForIdle();

	const [sidepaneExpandButton] = await Promise.all([
		waitForElement<HTMLButtonElement>(`button#sidepaneExpandButton`),
	]);

	console.debug("Microsoft Copilot Fixes - App Body", sidepaneExpandButton);

	watchForElement<HTMLDivElement>(
		`div.largeContainer-144`,
		`div.fui-InlineDrawer > div.fui-DrawerBody > div:nth-child(3)`,
		deleteElement,
	);

	watchForElement<HTMLDivElement>(
		`div.largeContainer-144`,
		`div#llm-web-ui-messageList-scrollable-container > div:nth-of-type(1) > div:nth-of-type(2)`,
		deleteElement,
	);

	sidepaneExpandButton.click();

	watchForElement<HTMLElement>(
		`div#app`,
		`pre > code`,
		e => {
			const text = e.innerText;

			let highlightedText: string;
			if (highlightedCodeCache.has(text)) {
				highlightedText = highlightedCodeCache.get(text)!;
			} else {
				highlightedText = hljs.highlightAuto(text).value;
				highlightedCodeCache.set(text, highlightedText);
			}

			e.innerHTML = highlightedText;
		},
	);
}

main();
