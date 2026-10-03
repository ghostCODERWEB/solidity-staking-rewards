export async function suite(h) {
  const stake = await h.token();
  const reward = await h.token();
  const c = await h.deploy("StakingRewards", [
    stake.target,
    reward.target,
    h.addresses[0],
  ]);
  await h.tx(stake.approve(c.target, 1000));
  await h.tx(reward.approve(c.target, 10000));
  await h.test("schedule requires admin", () =>
    h.revert(() => c.connect(h.signers[1]).notify(1000, 100)),
  );
  await h.tx(c.stake(100));
  await h.tx(c.notify(1000, 100));
  await h.test("funded emissions accrue", async () => {
    await h.mine(50);
    h.ok((await c.earned(h.addresses[0])) >= 500n);
  });
  await h.test("claim pays reward token", async () => {
    const before = await reward.balanceOf(h.addresses[0]);
    await h.tx(c.claim());
    h.ok((await reward.balanceOf(h.addresses[0])) > before);
  });
  await h.test("overwithdraw rejected", () => h.revert(() => c.withdraw(101)));
  await h.test("pause keeps principal exit available", async () => {
    await h.tx(c.setPaused(true));
    await h.revert(() => c.stake(1));
    await h.tx(c.withdraw(100));
    h.eq(await c.totalStaked(), 0n);
  });
  await h.test("same asset configuration rejected", () =>
    h.revert(() =>
      h.deploy("StakingRewards", [stake.target, stake.target, h.addresses[0]]),
    ),
  );
}
