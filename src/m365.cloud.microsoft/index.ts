import { waitForIdle, waitForElement, deleteElement } from "../lib/common.js";

async function main() {
	await waitForIdle();

	const [feedbackButton, mailButton] = await Promise.all([
		waitForElement<HTMLDivElement>(`div#HeaderButtonRegion > div#ShellFeedback_container`),
		waitForElement<HTMLDivElement>(`div#HeaderButtonRegion > div#O365_MainLink_Day_container`),
	]);

	console.debug("Microsoft Copilot Fixes - Outer UI", feedbackButton, mailButton);

	deleteElement(feedbackButton);
	deleteElement(mailButton);
}

main();
