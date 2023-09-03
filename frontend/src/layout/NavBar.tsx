function NavBar() {
  return (<div className="w-full h-16 mb-8 bg-red-800">
    <div className="relative w-full top-[25%]">
      <div className="ml-3">
        <a href="/" className="bg-slate-400 w-20 h-8 text-center text-lg float-left mr-5">&lt;LOGO&gt;</a>
        <a href="/" className="text-xl p-3">Home</a>
        <a href="/scheduleBuilder" className="text-xl p-3">Scheduler</a>
        <a href="/about" className="text-xl p-3">About</a>
      </div>
    </div>
  </div>)
}

export default NavBar