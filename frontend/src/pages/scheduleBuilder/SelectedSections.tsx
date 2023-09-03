import { AppDispatch, RootState } from '@/store';
import { SelectedSection } from '@/catalog';
import { useSelector, useDispatch } from 'react-redux';
import { removeSection } from '@/features/schedule';
import ResultRow from './ResultRow';
function SelectedSections () {
  const scheduleState = useSelector((store: RootState) => store.schedule)

  return (<div className='overflow-y-auto h-full'>
    {Object.entries(scheduleState.selected).map(([_crn, section]) => {return(<SelectedRow section={section}/>)})}
  </div>)
}

const SelectedRow = ({section}: {section: SelectedSection}) => {
  const dispatch = useDispatch<AppDispatch>()

  const dropResult = () => {
    dispatch(removeSection(section.section))
  }

  return(<div style={{gridTemplateAreas:'\
    ". display" \
    "close display" \
    "color display" \
    ". display" \
  '}} className='grid grid-rows-[1fr_60px_60px_1fr] grid-cols-[30px_1fr]'>
    <div style={{'gridArea':'close'}}><button onClick={dropResult} className='border-2 w-6 h-10 m-1 bg-slate-100 font-bold'>X</button></div>
    <div style={{'gridArea':'color'}}><button style={{backgroundColor: section.color}} className={`border-2 w-6 h-10 m-1`}></button></div>
    <div style={{'gridArea':'display'}}><ResultRow section={section.section}/></div>
  </div>)
}

export default SelectedSections