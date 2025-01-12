const querySelector = document.querySelector.bind(document);

export function sleep(durationSeconds: number): Promise<void> {
	return new Promise((fulfill, reject) => {
		setTimeout(() => {
			fulfill();
		}, durationSeconds * 1000)
	});
}

export function waitForIdle(): Promise<void> {
	return new Promise((fulfill, reject) => {
		setTimeout(() => {
			queueMicrotask(() => {
				setTimeout(() => {
					fulfill();
				}, 0);
			});
		}, 0)
	});
}

export async function waitForElement<E extends Element = Element>(selector: string): Promise<E> {
	let element: E | null = null;

	for (let i = 0; i < 1000; i++) {
		element = querySelector(selector);

		if (element) {
			return element;
		}

		await sleep(0.1);
	}

	throw new Error(`Could not find element with selector '${selector}'!`);
}

export function deleteElement(element: HTMLElement | null | undefined) {
	if (!element) {
		return;
	}

	const { style } = element;

	if (style) {
		style.display    = "none";
		style.visibility = "hidden";
	}

	element.innerHTML = "";
	element.replaceChildren();
	element.remove();
}

export function watchForElement<E extends HTMLElement = HTMLElement>(
	containerSelector: string,
	elementSelector: string,
	action: (element: E, mutationList: MutationRecord[]) => HTMLElement | void,
	runImmediatley: boolean = true,
): MutationObserver | void {
	const container = querySelector(containerSelector);

	if (!container) {
		return;
	}

	let isLocked = false;
	const callback: MutationCallback = (mutationList, observer) => {
		if (isLocked) {
			return;
		}

		isLocked = true;

		try {
			const element = querySelector<E>(elementSelector);
	
			if (!element) {
				return;
			}
	
			const newElement = action(element, mutationList);
	
			if (!newElement) {
				return;
			}
	
			element.replaceWith(newElement);
		} finally {
			queueMicrotask(() => {
				isLocked = false;
			});
		}
	};

	const observer = new MutationObserver(callback);

	observer.observe(container, {
		attributes: true,
		childList:  true,
		subtree:    true,
	});

	if (runImmediatley) {
		callback([], observer);
	}

	return observer;
}

export function makeElement<
	N extends keyof HTMLElementTagNameMap,
>(
	tagName: N,
	props?: Partial<{ [P in keyof HTMLElementTagNameMap[N]]: HTMLElementTagNameMap[N][P] }>,
	children?: (
		HTMLElementTagNameMap[N] extends ParentNode
		? (Node | string)[]
		: never
	),
): HTMLElementTagNameMap[N] {
	type T = HTMLElementTagNameMap[N];
	type K = keyof T;
	type V = T[K];

	const element: T = document.createElement<N>(tagName);

	if (props !== undefined) {
		for (const [key, value] of Object.entries(props) as [key: K, value: V][]) {
			element[key] = value;
		}
	}

	if (Array.isArray(children)) {
		element.replaceChildren(...children);
	}

	return element;
}
